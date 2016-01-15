class Shortener::ShortenedUrlsController < ActionController::Base
  include Shortener

  def show
    token = ::Shortener::ShortenedUrl.extract_token(params[:id])
    url   = ::Shortener::ShortenedUrl.fetch_with_token(token: token, additional_params: params, track: is_not_crawler?)
    redirect_to url[:url], status: :moved_permanently
  end

  private

  def is_not_crawler?
    CRAWLERS_USER_AGENT_LIST.exclude? request.user_agent
  end
end
