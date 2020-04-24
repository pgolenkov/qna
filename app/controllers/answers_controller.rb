class AnswersController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]

  expose :question, id: :question_id
  expose :answers, parent: :question
  expose :answer, scope: :with_attached_files, build: ->(params, scope){ current_user.answers.where(question: question).build(params) }

  def create
    authorize! :create, Answer
    answer.save
  end

  def update
    authorize! :update, answer
    answer.update(answer_params)
  end

  def make_best
    authorize! :make_best, answer
    @prev_best_answer = answer.question.best_answer
    answer.best!
  end

  def destroy
    authorize! :destroy, answer
    answer.destroy
  end

  private

  def answer_params
    params.require(:answer).permit(:body, links_attributes: [:name, :url], files: [])
  end
end
