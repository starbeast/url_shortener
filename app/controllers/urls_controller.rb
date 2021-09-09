class UrlsController < BaseController
  include GenericCrud

  skip_before_action :authorize, only: [:create, :redirect]

  def redirect
    service = UrlsService.new(shortened_url: params[:shortened_url])
    result = service.fetch
    return fail_json(result.errors, result.error_code || :not_found) unless result.success?

    url = result.object
    service.increment_viewed
    redirect_to url.url
  end

  private

  def create_params
    params.require(:url)
    params.permit(:url).merge(user_id: current_user&.id)
  end

  def destroy_params
    { user_id: current_user&.id, shortened_url: params[:id] }
  end

  def index_params
    { user_id: current_user&.id }
  end

  def index_options
    { with_id: false }
  end
end
