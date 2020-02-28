class AnswersChannel < ApplicationCable::Channel
  def subscribed
    stream_from "answers-#{params[:question_id]}"
  end
end
