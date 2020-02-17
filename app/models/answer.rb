class Answer < ApplicationRecord
  include Linkable

  belongs_to :question
  belongs_to :user

  has_many_attached :files

  validates :body, presence: true
  validates :question_id, uniqueness: { scope: :best }, if: :best?

  def best!
    transaction do
      question.answers.update_all(best: false)
      update!(best: true)
      question.award&.update!(user: user)
    end
  end
end
