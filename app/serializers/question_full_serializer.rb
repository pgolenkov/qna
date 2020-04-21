class QuestionFullSerializer < QuestionSerializer
  has_many :comments
  has_many :links
end
