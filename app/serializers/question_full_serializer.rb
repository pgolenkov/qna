class QuestionFullSerializer < QuestionSerializer
  has_many :comments
  has_many :links
  has_many :files, serializer: FileSerializer
end
