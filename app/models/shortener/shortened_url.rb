module Shortener
  class ShortenedUrl < ActiveRecord::Base
    
    UNIQUE_KEY_LENGTH = 5
    URL_PROTOCOL_HTTP = "http://"
    
    REGEX_HTTP_URL = /^\s*(http[s]?:\/\/)?[a-z0-9]+([-.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?\s*$/i
    REGEX_LINK_HAS_PROTOCOL = Regexp.new('\Ahttp:\/\/|\Ahttps:\/\/', Regexp::IGNORECASE)
    REGEX_EMAIL = /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
    
    validates_format_of :url, :with => REGEX_HTTP_URL, :allow_blank => true
    validates_presence_of :url
    validates_uniqueness_of :unique_key
    
    belongs_to :user # allows the shortened link to be associated with a user
    
    before_validation :clean_destination_url, :init_unique_key, :on => :create
    
    
    # ensure the url starts with it protocol
    def clean_destination_url
      if !self.url.blank? and self.url !~ REGEX_LINK_HAS_PROTOCOL
        self.url.insert(0, URL_PROTOCOL_HTTP)
      end
    end
    
    def init_unique_key
      # generate a unique key for the link
      begin
        # has about 50 million possible combos
        self.unique_key = ShortenedUrl::generate_unique_key
      end while ShortenedUrl::find_by_unique_key self.unique_key
    end
    
    # generate a shortened link from a url
    # link to a user if one specified
    # throw an exception if anything goes wrong
    def self.generate!(orig_url, user=nil)
      # don't want to generate the link if it has already been generated
      # so check the datastore
      uid = user.nil? ? nil : user.id
      sl = ShortenedUrl.find_by_url_and_user_id(orig_url, uid)
      
      return sl if sl
      
      # create the shortened link, storing it
      sl = ShortenedUrl.create!(:url => orig_url, :user => user)
      
      # return the url
      return sl
    end
    
    # return shortened url on success, nil on failure
    def self.generate(orig_url, user=nil)
      
      sl = nil
      
      begin
        sl = ShortenedUrl::generate!(orig_url, user)
      rescue
        sl = nil
      end
      
      return sl
    end
    
    
    
    private
    
    # generate a random string
    # future mod to allow specifying a more expansive charst, like utf-8 chinese
    def self.generate_unique_key(size = UNIQUE_KEY_LENGTH)
      # not doing uppercase as url is case insensitive
      charset = ('a'..'z').to_a + (0..9).to_a
      (0...size).map{ charset.to_a[rand(charset.size)] }.join
    end
      
  end
end
