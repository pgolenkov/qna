class QuestionsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]

  expose :questions, ->{ Question.all }
  expose :question, build: ->(params, scope){ current_user.questions.build(params) }

  def create
    if question.save
      redirect_to question, notice: 'Your question successfully created!'
    else
      render :new
    end
  end

  def destroy
    question.destroy
    redirect_to questions_path, notice: 'Your question successfully destroyed.'
  end

  private

  def question_params
    params.require(:question).permit(:title, :body)
  end

  def answer
    @answer ||= question.answers.build
  end
  helper_method :answer
end
