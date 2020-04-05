class QuestionsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :check_author, only: :update
  after_action :publish_question, only: :create

  expose :questions, ->{ Question.all }
  expose :question, scope: :with_attached_files, build: ->(params, scope){ current_user.questions.build(params) }

  authorize_resource

  def show
    gon.question_id = question.id
    gon.user_id = current_user.try(:id)
  end

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

  def destroy
    if current_user.author?(question)
      question.destroy
      flash[:notice] = 'Your question successfully destroyed.'
    end
    redirect_to questions_path
  end

  private

  def question_params
    params.require(:question).permit(:title, :body, links_attributes: [:name, :url], award_attributes: [:name, :image], files: [])
  end

  def answer
    @answer ||= question.answers.build
  end
  helper_method :answer

  def check_author
    head(:forbidden) unless current_user.author?(question)
  end

  def publish_question
    return if question.errors.any?

    ActionCable.server.broadcast('questions', question)
  end
end
