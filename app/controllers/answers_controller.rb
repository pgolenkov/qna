class AnswersController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :check_author, only: [:update, :destroy]

  expose :question, id: :question_id
  expose :answers, parent: :question
  expose :answer, scope: :with_attached_files, build: ->(params, scope){ current_user.answers.where(question: question).build(params) }

  def create
    answer.save
  end

  def update
    answer.update(answer_params)
  end

  def make_best
    if current_user.author?(answer.question)
      @prev_best_answer = answer.question.best_answer
      answer.best!
    else
      head :forbidden
    end
  end

  def destroy
    answer.destroy
  end

  private

  def answer_params
    params.require(:answer).permit(:body, links_attributes: [:name, :url], files: [])
  end

  def check_author
    head(:forbidden) unless current_user.author?(answer)
  end
end
