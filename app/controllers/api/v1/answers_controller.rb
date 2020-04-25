class Api::V1::AnswersController < Api::V1::BaseController
  load_and_authorize_resource

  def index
    render json: question.answers, each_serializer: AnswerListSerializer
  end

  def show
    render json: @answer
  end

  def create
    @answer = current_resource_owner.answers.where(question: question).build(answer_params)
    save_and_render(@answer, :created)
  end

  def update
    @answer.attributes = answer_params
    save_and_render(@answer)
  end

  def destroy
    @answer.destroy
    head :no_content
  end

  private

  def question
    @question ||= Question.find(params[:question_id])
  end

  def answer_params
    params.require(:answer).permit(:body, links_attributes: [:name, :url])
  end
end
