class Shortener::ShortenedUrl < ActiveRecord::Base

  REGEX_LINK_HAS_PROTOCOL = Regexp.new('\Ahttp:\/\/|\Ahttps:\/\/', Regexp::IGNORECASE)

  validates :url, presence: true

  # allows the shortened link to be associated with a user
  belongs_to :owner, polymorphic: true

  # exclude records in which expiration time is set and expiration time is greater than current time
  scope :unexpired, -> { where(arel_table[:expires_at].eq(nil).or(arel_table[:expires_at].gt(::Time.current.to_s(:db)))) }

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
  def self.generate!(destination_url, owner: nil, custom_key: nil, expires_at: nil, fresh: false)
    # if we get a shortened_url object with a different owner, generate
    # new one for the new owner. Otherwise return same object
    if destination_url.is_a? Shortener::ShortenedUrl
      if destination_url.owner == owner
        result = destination_url
      else
        result = generate!(destination_url.url,
                            owner:      owner,
                            custom_key: custom_key,
                            expires_at: expires_at,
                            fresh:      fresh
                          )
      end
    else
      scope = owner ? owner.shortened_urls : self

      if fresh
        result = scope.where(url: clean_url(destination_url)).create(unique_key: custom_key, expires_at: expires_at)
      else
        result = scope.where(url: clean_url(destination_url)).first_or_create(unique_key: custom_key, expires_at: expires_at)
      end
    end

    result
  end

  # return shortened url on success, nil on failure
  def self.generate(destination_url, owner: nil, custom_key: nil, expires_at: nil, fresh: false)
    begin
      generate!(destination_url, owner: owner, custom_key: custom_key, expires_at: expires_at, fresh: fresh)
    rescue => e
      logger.info e
      nil
    end
  end

  private

  # the create method changed in rails 4...
  CREATE_METHOD_NAME =
    if Rails::VERSION::MAJOR >= 4
      # And again in 4.0.6/4.1.2
      if ((Rails::VERSION::MINOR == 0) && (Rails::VERSION::TINY < 6)) ||
         ((Rails::VERSION::MINOR == 1) && (Rails::VERSION::TINY < 2))
        "create_record"
      else
        "_create_record"
      end
  else
    "create"
  end

  # we'll rely on the DB to make sure the unique key is really unique.
  # if it isn't unique, the unique index will catch this and raise an error
  define_method CREATE_METHOD_NAME do
    count = 0
    begin
      self.unique_key = generate_unique_key
      super()
    rescue ActiveRecord::RecordNotUnique, ActiveRecord::StatementInvalid => err
      if (count +=1) < 5
        logger.info("retrying with different unique key")
        retry
      else
        logger.info("too many retries, giving up")
        raise
      end
    end
  end

  def generate_unique_key
    charset = ::Shortener.key_chars
    (0...::Shortener.unique_key_length).map{ charset[rand(charset.size)] }.join
  end

end
