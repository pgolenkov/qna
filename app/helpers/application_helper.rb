module ApplicationHelper
  def question_cache_key(question)
    [signed_in?, can?(:create_vote, question), can?(:update, question), can?(:destroy, question), question]
  end

  def answer_cache_key(answer)
    [
      signed_in?,
      can?(:make_best, answer),
      can?(:create_vote, answer),
      can?(:update, answer),
      can?(:destroy, answer),
      answer
    ]
  end
end
