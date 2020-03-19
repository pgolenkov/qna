FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@test.com" }
    password { 'Aa123456' }
    password_confirmation { 'Aa123456' }
    confirmed_at { Time.current }

    trait(:not_confirmed) do
      confirmed_at { nil }
    end
  end
end
