class Shortener::ShortenedUrlsController < ActionController::Base

  def show
    token = ::Shortener::ShortenedUrl.extract_token(params[:id])
    url   = ::Shortener::ShortenedUrl.fetch_with_token(token: token, additional_params: permitted_params)
    redirect_to url[:url], status: :moved_permanently
  end

  private

  def permitted_params
    params.permit!.except(:controller, :action, :id)
  end
end
