class CommentsController < ApplicationController
  before_action :authenticate_user!
  after_action :publish_comment, only: :create

  def create
    @comment = current_user.comments.create(comment_params.merge(commentable: commentable))
  end

  private

  def comment_params
    params.require(:comment).permit(:body)
  end

  def publish_comment
    return if @comment.errors.any?

    question_id = commentable.is_a?(Question) ? commentable.id : commentable.question_id
    ActionCable.server.broadcast("comments-#{question_id}", @comment)
  end

  def commentable
    @commentable ||= params[:commentable_type].classify.constantize.find(params[:commentable_id])
  end
end
