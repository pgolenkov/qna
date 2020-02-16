class Answer < ApplicationRecord
  belongs_to :question
  belongs_to :user
  has_many :links, as: :linkable, dependent: :destroy

  has_many_attached :files
  accepts_nested_attributes_for :links, reject_if: :all_blank, allow_destroy: true

  validates :body, presence: true
  validates :question_id, uniqueness: { scope: :best }, if: :best?

  def best!
    transaction do
      question.answers.update_all(best: false)
      update!(best: true)
      question.award.user = user if question.award
    end
  end
end
