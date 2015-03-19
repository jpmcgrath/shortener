class Shortener::ShortenedUrl < ActiveRecord::Base

  URL_PROTOCOL_HTTP = "http://"
  REGEX_LINK_HAS_PROTOCOL = Regexp.new('\Ahttp:\/\/|\Ahttps:\/\/', Regexp::IGNORECASE)

  validates :url, :presence => true

  # allows the shortened link to be associated with a user
  belongs_to :owner, :polymorphic => true

  # ensure the url starts with it protocol and is normalized
  def self.clean_url(url)
    return nil if url.blank?
    url = URL_PROTOCOL_HTTP + url.strip unless url =~ REGEX_LINK_HAS_PROTOCOL
    URI.parse(url).normalize.to_s
  end

  # generate a shortened link from a url
  # link to a user if one specified
  # throw an exception if anything goes wrong
  def self.generate!(orig_url, owner=nil, custom_key=nil)
    # if we get a shortened_url object with a different owner, generate
    # new one for the new owner. Otherwise return same object
    if orig_url.is_a?(Shortener::ShortenedUrl)
      return orig_url.owner == owner ? orig_url : generate!(orig_url.url, owner, custom_key)
    end

    # don't want to generate the link if it has already been generated
    # so check the datastore
    cleaned_url = clean_url(orig_url)
    scope = owner ? owner.shortened_urls : self
    if custom_key
      scope.where(:url => cleaned_url, :unique_key => custom_key).first_or_create
    else
      scope.where(:url => cleaned_url).first_or_create
    end
  end

  # return shortened url on success, nil on failure
  def self.generate(orig_url, owner=nil, custom_key=nil)
    begin
      generate!(orig_url, owner, custom_key)
    rescue
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
    return super() if self.unique_key

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

  # generate a random string
  # future mod to allow specifying a more expansive charst, like utf-8 chinese
  def generate_unique_key
    # not doing uppercase as url is case insensitive
    charset = ::Shortener.key_chars
    (0...::Shortener.unique_key_length).map{ charset[rand(charset.size)] }.join
  end

end
