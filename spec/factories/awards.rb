FactoryBot.define do
  factory :award do
    question
    sequence(:name) { |n| "Award name #{n}" }
    image { Rack::Test::UploadedFile.new('public/apple-touch-icon.png', 'image/png') }
  end
end
