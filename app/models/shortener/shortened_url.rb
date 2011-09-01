module Shortener
  class ShortenedUrl < ActiveRecord::Base
    
    belongs_to :user # allows the shortened link to be associated with a user
    
    # this is best placed in your env files so you can have localhost for dev
    #HOST_NAME = 'dealush.com'
    UNIQUE_KEY_LENGTH = 5
    # it can be useful to easily know how long the shortened link will be
    # the start of the link for dealush is http://dealush.com/s/ (21 chars)
    # change the number as needed for your site
    #LENGTH = 21 + UNIQUE_KEY_LENGTH
    
    # generate a shortened link from a url
    # link to a user if one specified
    def self.generate(orig_url, user=nil)
      # don't want to generate the link if it has already been generated
      # so check the datastore
      uid = user.nil? ? nil : user.id
      sl = ShortenedUrl.find_by_url_and_user_id(orig_url, uid)
      
      return sl if sl
      
      ukey = nil
      
      # generate a unique key for the link
      begin
        # has about 50 million possible combos
        ukey = self.generate_unique_key
        end while ShortenedUrl.find_by_unique_key ukey
      
      # create the shortened link, storing it
      sl = ShortenedUrl.create(:url => orig_url, :unique_key => ukey, :user => user)
      
      # return the url
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
