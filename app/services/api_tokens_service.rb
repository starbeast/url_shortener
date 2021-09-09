# frozen_string_literal: true

class ApiTokensService < BaseService
  def fetch_all(page, per_page)
    return result.fail(I18n.t('exceptions.api_tokens.authorized_user_required'), :unauthorized) if @params[:user_id].blank?

    tokens = ApiToken.where(user_id: @params[:user_id]).page(page).per(per_page)
    result.tap { |r| r.objects = tokens }
  end

  def destroy
    token = ApiToken.find_by(id: @params[:id])
    return result.fail(I18n.t('exceptions.not_found'), :not_found) if token.nil?

    token.destroy
    result
  end

  def create
    token = ApiToken.generate(@params)
    return result.fail(token.errors.full_messages) unless token.persisted?

    result.tap { |r| r.object = token }
  end
end
