require "addressable/uri"

class Shortener::ShortenedUrlsController < ActionController::Base

  # find the real link for the shortened link key and redirect
  def show
    # only use the leading valid characters
    token = /^([#{Shortener.key_chars.join}]*).*/.match(params[:id])[1]

    # pull the link out of the db
    sl = ::Shortener::ShortenedUrl.find_by_unique_key(token)

    if sl
      # don't want to wait for the increment to happen, make it snappy!
      # this is the place to enhance the metrics captured
      # for the system. You could log the request origin
      # browser type, ip address etc.
      Thread.new do
        sl.increment!(:use_count)
        ActiveRecord::Base.connection.close
      end
      # do a 301 redirect to the destination url
      redirect_to redirect_url_with_params(sl), :status => :moved_permanently
    else
      # if we don't find the shortened link, redirect to the root
      # make this configurable in future versions
      redirect_to '/'
    end
  end

  private

  def redirect_url_with_params(short_link)
    uri = Addressable::URI.parse(short_link.url)
    if uri.query_values || request.query_parameters.any?
      params = uri.query_values || {}
      uri.query_values = params.merge(request.query_parameters)
    end
    uri.to_s
  end

end
