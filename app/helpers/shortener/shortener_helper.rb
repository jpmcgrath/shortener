module Shortener::ShortenerHelper
  
  def shortened_url(original_url, user=nil)
    
    short_url = ShortenedUrl::generate(original_url, user)
    
    return translate_url(short_url.unique_key)
    
  end

end