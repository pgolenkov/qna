FactoryBot.define do
  factory :subscription do
    user
    association :subscribable, factory: :question
  end
end
