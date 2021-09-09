class ApiTokensController < BaseController
  include GenericCrud

  private

  def create_params
    params.require(:alias)
    params.permit(:alias, :expires_at).merge(user_id: current_user&.id)
  end

  def index_params
    { user_id: current_user&.id }
  end
end
