class SessionsController < BaseController
  skip_before_action :authorize
  after_action :set_csrf_cookie, only: [:login, :sign_up], if: ->{ response.status == 200 }

  def login
    result = UsersService.new.lookup_for_login(params[:email], params[:password])
    return fail_json(result.errors, result.error_code || :unauthorized) unless result.success?
    session[:user_id] = result.object.id
    Rails.logger.debug(session.options.instance_eval { @by }.default_options)
    render_ok
  end

  def logout
    reset_session
    render_ok
  end

  # we should only approve users after an email or other type of confirmation
  # but it's a bit out of scope of the test task
  def sign_up
    result = UsersService.new(create_user_params).create(params[:password])
    return fail_json(result.errors, result.error_code || :unprocessable_entity) unless result.success?

    session[:user_id] = result.object.id
    render_ok
  end

  private

  def render_ok
    render json: '{}', status: 200
  end

  def create_user_params
    params.require(:email)
    params.require(:password)
    params.permit(:email)
  end
end
