class AnswersController < ApplicationController
  expose :question, id: :question_id
  expose :answer, parent: :question

  def create
    if answer.save
      redirect_to question
    else
      render :new
    end
  end

  private

  def answer_params
    params.require(:answer).permit(:body)
  end
end
