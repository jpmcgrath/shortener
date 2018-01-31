module Shortener::ShortenerHelper

  # generate a url from a url string
  def short_url(url, owner: nil, custom_key: nil, expires_at: nil, fresh: false, category: nil, reference: nil, reference_id: nil, url_options: {})
    short_url = Shortener::ShortenedUrl.generate(
      url,
      owner:        owner,
      custom_key:   custom_key,
      expires_at:   expires_at,
      fresh:        fresh,
      category:     category,
      reference:    reference,
      reference_id: reference_id
    )

    if short_url
      options = { controller: :"/shortener/shortened_urls", action: :show, id: short_url.unique_key, only_path: false }.merge(url_options)
      url_for(options)
    else
      url
    end
  end

end
