class AnswerListSerializer < ActiveModel::Serializer
  attributes :id, :body, :rating, :best?, :created_at, :updated_at
  belongs_to :user
end
