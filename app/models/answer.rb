class Answer < ApplicationRecord
  belongs_to :question
  belongs_to :user

  validates :body, presence: true
  validates :question_id, uniqueness: { scope: :best }, if: :best?

  def best!
    transaction do
      question.answers.update_all(best: false)
      update!(best: true)
    end
  end
end
