FactoryBot.define do
  factory :question do
    sequence(:title) { |n| "MyString#{n}" }
    body { "MyText" }
    user

    trait :invalid do
      title { nil }
    end
  end
end
