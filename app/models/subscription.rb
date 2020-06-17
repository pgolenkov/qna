class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :question, touch: true

  validates :user, uniqueness: { scope: :question_id }
end
