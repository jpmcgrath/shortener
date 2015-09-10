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
      redirect_to sl.url, status: :moved_permanently
    else
      # if we don't find the shortened link, redirect to the root
      # make this configurable in future versions
      redirect_to '/'
    end
  end

end
