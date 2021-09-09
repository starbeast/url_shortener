FactoryBot.define do
  factory :api_token do
    add_attribute :alias, &->{ FFaker::Lorem.word }
    token { Digest::SHA256.base64digest(FFaker::Lorem.word) }
    expires_at { 1.month.from_now }
    user
  end
end
