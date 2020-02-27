FactoryBot.define do
  factory :comment do
    user
    association(:commentable, factory: :question)
    sequence(:body) { |n| "My comment #{n}" }
  end
end
