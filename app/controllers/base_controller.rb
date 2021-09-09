# frozen_string_literal: true

class BaseController < ApplicationController
  respond_to :json

  include ActionController::Cookies
  include ActionController::RequestForgeryProtection

  before_action :set_csrf_cookie, if: :cookie_session
  before_action :authorize
  protect_from_forgery with: :exception, if: :cookie_session

  rescue_from StandardError, RuntimeError, with: :catch_error
  rescue_from ActiveModel::UnknownAttributeError, ActiveRecord::RecordInvalid, ActionController::ParameterMissing,
              ActiveRecord::NotNullViolation, ActiveRecord::RecordNotUnique, with: :unprocessable_entity
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActionController::InvalidAuthenticityToken, with: :unauthorized

  DEFAULT_PAGE = 1
  DEFAULT_PER_PAGE = 25

  def serialize_data(obj, opts = {})
    ActiveModelSerializers::SerializableResource.new(obj, opts).as_json
  end

  def serialize_array(objs, opts = {})
    ActiveModel::Serializer::CollectionSerializer.new(objs, opts).as_json
  end

  def pagination_data(scope)
    {
      total: scope.total_count,
      page: scope.current_page,
      per_page: scope.limit_value,
      total_pages: scope.total_pages,
      is_last_page: scope.last_page? || scope.current_page > scope.total_pages
    }
  end

  def page
    @page ||= params[:page].present? ? params[:page].to_i : DEFAULT_PAGE
  end

  def per_page
    @per_page ||= params[:per_page].present? ? params[:per_page].to_i : DEFAULT_PER_PAGE
  end

  private

  def cookie_session
    session[:user_id].present?
  end

  def set_csrf_cookie
    cookies['CSRF-TOKEN'] = form_authenticity_token
  end

  def fail_json(error_messages, status = nil)
    errors = error_messages.is_a?(Array) ? error_messages : [error_messages]
    render json: { errors: errors }.to_json, status: status
  end

  def unprocessable_entity(exception)
    catch_error(exception, :unprocessable_entity)
  end

  def unauthorized
    fail_json(I18n.t('exceptions.unauthorized'), :unauthorized)
  end

  def catch_error(exception, status = 500)
    Rails.logger.debug exception.message
    exception.backtrace.each { |backtrace| Rails.logger.debug backtrace }
    fail_json(exception.message, status)
  end

  def record_not_found
    fail_json(I18n.t('exceptions.not_found'), :not_found)
  end

  def current_user
    @current_user ||= lookup_auth_token || lookup_session
  end

  def lookup_auth_token
    token = request.env['HTTP_AUTHORIZATION']
    return unless token&.length == 32

    ApiToken.lookup(token)&.user
  end

  def lookup_session
    User.find_by(id: session[:user_id])
  end

  def authorize
    unauthorized if current_user.blank?
  end
end
