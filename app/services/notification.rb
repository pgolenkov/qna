class Services::Notification
  def new_answer(answer)
    user = answer.question.user
    NotificationMailer.new_answer(user, answer).deliver_later
  end
end
