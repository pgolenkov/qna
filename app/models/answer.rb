class Answer < ApplicationRecord
  include Attachable
  include Linkable
  include Votable

  belongs_to :question
  belongs_to :user

  validates :body, presence: true
  validates :question_id, uniqueness: { scope: :best }, if: :best?

  def best!
    transaction do
      question.answers.update_all(best: false)
      update!(best: true)
      question.award&.update!(user: user)
    end
  end

  def as_json(options = nil)
    super(
      methods: [:rating, :files_as_json],
      include: [
        :question,
        links: { methods: [:gist_raw] }
      ]
    )
  end
end
