require 'voight_kampff'

class Shortener::ShortenedUrlsController < ActionController::Base
  include Shortener

  def show
    token = ::Shortener::ShortenedUrl.extract_token(params[:id])
    track = Shortener.ignore_robots.blank? || request.human?
    url   = ::Shortener::ShortenedUrl.fetch_with_token(token: token, track: track)
    redirect_to url[:url], status: :moved_permanently
  end
end
