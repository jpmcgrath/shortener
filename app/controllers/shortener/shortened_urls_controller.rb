require 'voight_kampff'

class Shortener::ShortenedUrlsController < ActionController::Base
  include Shortener

  def show
    token = ::Shortener::ShortenedUrl.extract_token(params[:id])
    url   = ::Shortener::ShortenedUrl.fetch_with_token(token: token, additional_params: params, track: request.human?)
    redirect_to url[:url], status: :moved_permanently
  end
end
