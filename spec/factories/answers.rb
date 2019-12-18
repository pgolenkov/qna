FactoryBot.define do
  factory :answer do
    user
    question
    sequence(:body) { |n| "My Answer #{n}" }

    trait :invalid do
      body { nil }
    end

    trait :best do
      best { true }
    end
  end
end
