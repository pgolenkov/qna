class Question < ApplicationRecord
  has_many :answers, dependent: :destroy
  belongs_to :user
  
  validates :title, :body, presence: true
  validates :title, uniqueness: true
end
