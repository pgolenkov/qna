class Api::V1::AnswersController < Api::V1::BaseController
  load_and_authorize_resource

  def index
    render json: question.answers
  end

  def show
    render json: @answer, serializer: AnswerFullSerializer
  end

  def create
    @answer = current_resource_owner.answers.where(question: question).build(answer_params)
    if @answer.save
      render json: @answer, serializer: AnswerFullSerializer, status: :created
    else
      render json: { errors: @answer.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def question
    @question ||= Question.find(params[:question_id])
  end

  def answer_params
    params.require(:answer).permit(:body, links_attributes: [:name, :url])
  end
end
