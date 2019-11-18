class AnswersController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]

  expose :question, id: :question_id
  expose :answer, parent: :question, build: ->(params, scope){ current_user.answers.where(question: question).build(params) }

  def create
    if answer.save
      redirect_to question, notice: 'Your answer successfully created!'
    else
      render 'questions/show'
    end
  end

  def destroy
    if current_user.author?(answer)
      answer.destroy
      flash[:notice] = 'Your answer successfully destroyed.'
    end
    redirect_to question
  end

  private

  def answer_params
    params.require(:answer).permit(:body)
  end
end
