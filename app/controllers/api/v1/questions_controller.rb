class Api::V1::QuestionsController < Api::V1::BaseController
  load_and_authorize_resource

  def index
    render json: Question.all
  end

  def show
    render json: @question, serializer: QuestionFullSerializer
  end

  def create
    @question = current_resource_owner.questions.build(question_params)
    if @question.save
      render json: @question, serializer: QuestionFullSerializer, status: :created
    else
      render json: { errors: @question.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @question.update(question_params)
      render json: @question, serializer: QuestionFullSerializer
    else
      render json: { errors: @question.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @question.destroy
    head :no_content
  end

  private

  def question_params
    params.require(:question).permit(:title, :body, links_attributes: [:name, :url])
  end
end
