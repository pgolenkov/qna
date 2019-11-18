FactoryBot.define do
  factory :question do
    sequence(:title) { |n| "My Question #{n}" }
    body { "My Question text" }
    user

    trait :invalid do
      title { nil }
    end
  end
end
