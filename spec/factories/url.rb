FactoryBot.define do
  factory :url do
    url { FFaker::Internet.http_url }
    sequence :shortened_url do |n|
      n.to_s.ljust(10, 'a')
    end
    times_followed { 0 }

    trait :with_user do
      user
    end

    factory :url_for_user, traits: [:with_user]
  end
end
