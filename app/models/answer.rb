class Answer < ApplicationRecord
  include Attachable
  include Linkable
  include Votable
  include Commentable

  belongs_to :question
  belongs_to :user

  after_create :send_notification
  after_commit :publish, on: :create

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
        :comments,
        links: { methods: [:gist_raw] }
      ]
    )
  end

  private

  def send_notification
    Services::Notification.new.new_answer(self)
  end

  def publish
    return if self.errors.any?

    ActionCable.server.broadcast("answers-#{question_id}", self)
  end
end
