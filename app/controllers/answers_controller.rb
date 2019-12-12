class AnswersController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]

  expose :question, id: :question_id
  expose :answers, parent: :question
  expose :answer, build: ->(params, scope){ current_user.answers.where(question: question).build(params) }

  def create
    answer.save
  end

  def update
    if current_user.author?(answer)
      answer.update(answer_params)
    else
      head :forbidden
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
