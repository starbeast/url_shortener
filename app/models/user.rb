class User < ApplicationRecord
  include BCrypt
  has_many :urls
  has_many :api_tokens

  validates :email, presence: true

  def password
    @password ||= Password.new(password_hash)
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.password_hash = @password
  end
end
