# frozen_string_literal: true

class UsersService < BaseService
  def create(password)
    user = User.new(@params)
    return result.fail(I18n.t('exceptions.blank_password')) if password.blank?

    user.password = password
    return result.fail(user.errors.full_messages) unless user.valid?

    user.save!
    result.tap { |r| r.object = user }
  rescue ActiveRecord::RecordNotUnique
    result.fail(I18n.t('exceptions.user_already_exists'))
  end

  def lookup_for_login(email, password)
    user = User.find_by(email: email)
    return result.fail(I18n.t('exceptions.wrong_login_credentials')) if user.nil? || user.password != password

    result.tap { |r| r.object = user }
  end
end
