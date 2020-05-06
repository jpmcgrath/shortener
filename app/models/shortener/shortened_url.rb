class Shortener::ShortenedUrl < ActiveRecord::Base

  REGEX_LINK_HAS_PROTOCOL = Regexp.new('\Ahttp:\/\/|\Ahttps:\/\/', Regexp::IGNORECASE)

  validates :url, presence: true

  around_create :generate_unique_key

  # allows the shortened link to be associated with a user
  if ActiveRecord::VERSION::MAJOR >= 5
    # adds rails 5 compatibility to have nil values as owner
    belongs_to :owner, polymorphic: true, optional: true
  else
    belongs_to :owner, polymorphic: true
  end

  # exclude records in which expiration time is set and expiration time is greater than current time
  scope :unexpired, -> { where(arel_table[:expires_at].eq(nil).or(arel_table[:expires_at].gt(::Time.current.to_s(:db)))) }

  attr_accessor :custom_key

  # ensure the url starts with it protocol and is normalized
  def self.clean_url(url)

    url = url.to_s.strip
    if url !~ REGEX_LINK_HAS_PROTOCOL && url[0] != '/'
      url = "/#{url}"
    end
    URI.parse(url).normalize.to_s
  end

  # generate a shortened link from a url
  # link to a user if one specified
  # throw an exception if anything goes wrong
  def self.generate!(destination_url, owner: nil, custom_key: nil, expires_at: nil, fresh: false, category: nil)
    # if we get a shortened_url object with a different owner, generate
    # new one for the new owner. Otherwise return same object
    if destination_url.is_a? Shortener::ShortenedUrl
      if destination_url.owner == owner
        destination_url
      else
        generate!(
          destination_url.url,
          owner:      owner,
          custom_key: custom_key,
          expires_at: expires_at,
          fresh:      fresh,
          category:   category
        )
      end
    else
      scope = owner ? owner.shortened_urls : self
      creation_method = fresh ? 'create' : 'first_or_create'

      url_to_save = Shortener.auto_clean_url ? clean_url(destination_url) : destination_url
      scope.where(url: url_to_save, category: category).send(
        creation_method,
        custom_key: custom_key,
        expires_at: expires_at
      )
    end
  end

  # return shortened url on success, nil on failure
  def self.generate(destination_url, owner: nil, custom_key: nil, expires_at: nil, fresh: false, category: nil)
    begin
      generate!(
        destination_url,
        owner: owner,
        custom_key: custom_key,
        expires_at: expires_at,
        fresh: fresh,
        category: category
      )
    rescue => e
      logger.info e
      nil
    end
  end

  def self.extract_token(token_str)
    # only use the leading valid characters
    # escape to ensure custom charsets with protected chars do not fail
    /^([#{Regexp.escape(Shortener.key_chars.join)}]*).*/.match(token_str)[1]
  end

  def self.fetch_with_token(token: nil, additional_params: {}, track: true)
    shortened_url = ::Shortener::ShortenedUrl.unexpired.where(unique_key: token).first

    url = if shortened_url
      shortened_url.increment_usage_count if track
      merge_params_to_url(url: shortened_url.url, params: additional_params)
    else
      Shortener.default_redirect || '/'
    end

    { url: url, shortened_url: shortened_url }
  end

  def self.merge_params_to_url(url: nil, params: {})
    if params.respond_to?(:permit!)
      params = params.permit!.to_h.with_indifferent_access.except!(:id, :action, :controller)
    end

    if Shortener.subdomain
      params.try(:except!, :subdomain) if params[:subdomain] == Shortener.subdomain
    end

    if params.present?
      uri = URI.parse(url)
      existing_params = Rack::Utils.parse_nested_query(uri.query)
      uri.query       = existing_params.with_indifferent_access.merge(params).to_query
      url = uri.to_s
    end

    url
  end

  def increment_usage_count
    self.class.increment_counter(:use_count, id)
  end

  def to_param
    unique_key
  end

  private

  def self.unique_key_candidate
    charset = ::Shortener.key_chars
    (0...::Shortener.unique_key_length).map{ charset[rand(charset.size)] }.join
  end

  def generate_unique_key(retries = Shortener.persist_retries)
    begin
      self.unique_key = custom_key || self.class.unique_key_candidate
      self.custom_key = nil
    end while self.class.unscoped.exists?(unique_key: unique_key)

    yield
  rescue ActiveRecord::RecordNotUnique
    if retries <= 0
      raise
    else
      retries -= 1
      retry
    end
  end
end
