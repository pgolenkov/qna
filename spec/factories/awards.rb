FactoryBot.define do
  factory :award do
    sequence(:name) { |n| "Award name #{n}" }
  end
end
