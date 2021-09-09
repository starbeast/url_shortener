FactoryBot.define do
  factory :user do
    email { FFaker::Internet.email }
    password_hash { BCrypt::Password.create('password') }
  end
end
