class Answer < ApplicationRecord
  belongs_to :question
  belongs_to :user

  validates :body, presence: true
  validates :question_id, uniqueness: { scope: :best }, if: :best?
end
