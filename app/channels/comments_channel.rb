class CommentsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "comments-#{params[:question_id]}"
  end
end
