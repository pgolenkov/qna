class Question < ApplicationRecord
  include Attachable
  include Linkable
  include Votable
  include Commentable

  has_many :answers, -> { order(best: :desc) }, dependent: :destroy
  has_one :award, dependent: :destroy
  belongs_to :user
  has_many :subscriptions, dependent: :destroy

  after_create :subscribe_author
  after_commit :publish, on: :create

  accepts_nested_attributes_for :award, reject_if: proc { |attributes| attributes['name'].blank? }

  validates :title, :body, presence: true
  validates :title, uniqueness: true

  def best_answer
    answers.find_by(best: true)
  end

  private

  def subscribe_author
    self.subscriptions.create(user: user)
  end

  def publish
    return if self.errors.any?

    ActionCable.server.broadcast('questions', self)
  end
end
