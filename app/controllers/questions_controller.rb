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
    if current_user.questions.include?(question)
      question.destroy
      flash[:notice] = 'Your question successfully destroyed.'
    end
    redirect_to questions_path
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
