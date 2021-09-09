# frozen_string_literal: true

class ApiToken < ApplicationRecord
  belongs_to :user
  attr_accessor :raw_token

  validates :alias, :expires_at, :token, presence: true

  class << self
    def generate(params)
      token = SecureRandom.hex(16)
      hashed_token = hash_token(token)
      user_auth_token = create(
        user_id: params[:user_id], token: hashed_token,
        alias: params[:alias], expires_at: params[:expires_at] || default_expires_at
      )
      user_auth_token.tap { |auth_token| auth_token.raw_token = token }
    end

    def lookup(raw_token)
      hashed_token = hash_token(raw_token)
      where(token: hashed_token).where('expires_at > ?', Time.zone.now).first
    end

    def hash_token(token)
      Digest::SHA256.base64digest(token)
    end

    private

    def default_expires_at
      1.month.from_now
    end
  end
end
