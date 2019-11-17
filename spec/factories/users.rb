FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@test.com" }
    password { 'Aa123456' }
    password_confirmation { 'Aa123456' }
  end
end
