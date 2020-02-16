class Award < ApplicationRecord
  belongs_to :question
  has_one :user_award, dependent: :destroy
  has_one :user, through: :user_award

  validates :name, presence: true
  has_one_attached :image

  validates :image, attached: true, content_type: [:png, :jpg, :jpeg, :gif]
end
