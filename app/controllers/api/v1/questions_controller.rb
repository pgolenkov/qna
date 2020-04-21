class Api::V1::QuestionsController < Api::V1::BaseController
  def index
    render json: Question.all
  end

  def show
    @question = Question.find(params[:id])
    render json: @question, serializer: QuestionFullSerializer
  end
end
