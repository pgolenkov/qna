class QuestionsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]

  expose :questions, ->{ Question.all }
  expose :question, scope: :with_attached_files, build: ->(params, scope){ current_user.questions.build(params) }

  def show
    authorize! :show, question
    gon.question_id = question.id
    gon.user_id = current_user.try(:id)
  end

  def create
    authorize! :create, Question
    if question.save
      question.subscriptions.create(user: current_user)
      redirect_to question, notice: 'Your question successfully created!'
    else
      render :new
    end
  end

  def update
    authorize! :update, question
    question.update(question_params)
  end

  def destroy
    authorize! :destroy, question
    question.destroy
    redirect_to questions_path, notice: 'Your question successfully destroyed.'
  end

  private

  def question_params
    params.require(:question).permit(:title, :body, links_attributes: [:name, :url], award_attributes: [:name, :image], files: [])
  end

  def answer
    @answer ||= question.answers.build
  end
  helper_method :answer
end
