module Shortener::ShortenerHelper

  # generate a url from a url string
  def short_url(url, params={})
    short_url = Shortener::ShortenedUrl.generate(url, params)

    default_params = (Shortener.default_shortening_params || {})
    url_options = Shortener.adhoc_shortening_params[:url_options]
                    .merge(default_params[:url_options] || {})
                    .merge(params[:url_options] || {})

    if short_url
      options = {
        controller: :"shortener/shortened_urls",
        action: :show,
        id: short_url.unique_key,
        only_path: false
      }.merge(url_options)

      url_for(options)
    else
      url
    end
  end

end
