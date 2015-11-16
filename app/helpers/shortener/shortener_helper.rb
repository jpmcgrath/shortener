module Shortener::ShortenerHelper

  # generate a url from a url string
  def short_url(url, owner=nil)
    short_url = Shortener::ShortenedUrl.generate(url, owner)
    if short_url
      if host = Shortener.default_host.presence
        url_for(host: host, controller: :"shortener/shortened_urls", action: :show, id: short_url.unique_key, only_path: false)
      else
        url_for(controller: :"shortener/shortened_urls", action: :show, id: short_url.unique_key, only_path: false)
      end
    else
      url
    end
  end

end
