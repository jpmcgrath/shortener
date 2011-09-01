module Shortener::ShortenerHelper
  
  # generate a url from either a url string, or a shortened url object
  def shortened_url(url_object, user=nil)
    
    short_url = nil
    
    if url_object.class != String #== ShortenedUrl
      if user.nil?
        short_url = url_object
      else
        # if the user has passed in a shortened url, with a user, then 
        # work out the link for the shortened url and make another with the 
        # passed user
        short_url = ShortenedUrl.generate(shortened_url(url_object), user)
      end
    else
      short_url = ShortenedUrl.generate(url_object, user)
    end
    
    return short_url.nil? ? nil : shortener_translate_url(short_url.unique_key)
  end

end