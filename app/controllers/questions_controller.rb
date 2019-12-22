class QuestionsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :check_author, only: [:update, :remove_file]

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
    question.update(question_params)
  end

  def remove_file
    @file = question.files.find(params[:file_id])
    @file.purge
  rescue ActiveRecord::RecordNotFound
    head :not_found
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

  def check_author
    head(:forbidden) unless current_user.author?(question)
  end
end
