class QuestionsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]

  expose :questions, ->{ Question.all }
  expose :question, scope: :with_attached_files, build: ->(params, scope){ current_user.questions.build(params) }

  def create
    if question.save
      redirect_to question, notice: 'Your question successfully created!'
    else
      render :new
    end
  end

  def update
    if current_user.author?(question)
      question.update(question_params)
    else
      head :forbidden
    end
  end

  def destroy
    if current_user.author?(question)
      question.destroy
      flash[:notice] = 'Your question successfully destroyed.'
    end
    redirect_to questions_path
  end

  private

  def question_params
    params.require(:question).permit(:title, :body, files: [])
  end

  def answer
    @answer ||= question.answers.build
  end
  helper_method :answer
end
