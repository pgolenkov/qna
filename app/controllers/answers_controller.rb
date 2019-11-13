class AnswersController < ApplicationController
  expose :question, id: :question_id
  expose :answer, parent: :question

  def create
    if answer.save
      redirect_to question, notice: 'Your answer successfully created!'
    else
      render 'questions/show'
    end
  end

  private

  def answer_params
    params.require(:answer).permit(:body)
  end
end
