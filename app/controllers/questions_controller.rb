class QuestionsController < ApplicationController
  expose :questions, ->{ Question.all }
  expose :question

  def create
    if question.save
      redirect_to question, notice: 'Your question successfully created!'
    else
      render :new
    end
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
