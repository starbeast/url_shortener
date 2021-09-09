# frozen_string_liters: true

class UrlsService < BaseService
  def fetch_all(page, per_page)
    return result.fail(I18n.t('exceptions.urls.authorized_user_required'), :unauthorized) if @params[:user_id].blank?

    tokens = Url.where(user_id: @params[:user_id]).page(page).per(per_page)
    result.tap { |r| r.objects = tokens }
  end

  def destroy
    return result.fail(I18n.t('exceptions.urls.authorized_user_required'), :unauthorized) if @params[:user_id].blank?

    url = Url.find_by(user_id: @params[:user_id], shortened_url: @params[:shortened_url])
    return result.fail(I18n.t('exceptions.not_found'), :not_found) if url.nil?

    url.destroy
    result
  end

  def create
    url_service = ShortenedPathsService.new
    begin
      url = Url.create(@params.reverse_merge(shortened_url: url_service.lookup))
    rescue ActiveRecord::RecordNotUnique
      retry
    end
    return result.fail(url.errors.full_messages) unless url.persisted?

    result.tap { |r| r.object = url }
  end

  def increment_viewed
    Url.where(shortened_url: @params[:shortened_url]).update_all('times_followed = times_followed + 1')
  end

  def fetch
    url = Url.find_by(shortened_url: @params[:shortened_url])
    return result.fail(I18n.t('exceptions.not_found')) if url.nil?

    result.tap { |r| r.object = url }
  end
end
