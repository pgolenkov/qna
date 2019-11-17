require 'rails_helper'

RSpec.describe AnswersController, type: :controller do
  let(:question) { create :question }
  let(:user) { create :user }

  describe 'POST #create' do
    before { login(user) }

    context 'with valid params' do
      def post_answer
        post :create, params: { question_id: question.id, answer: attributes_for(:answer) }
      end

      it 'should create new answer for question' do
        expect { post_answer }.to change { question.answers.count }.by(1)
      end
      it 'should redirect to question' do
        post_answer
        expect(response).to redirect_to question
      end
    end
    context 'with invalid params' do
      def post_invalid_answer
        post :create, params: { question_id: question.id, answer: attributes_for(:answer, :invalid) }
      end

      it 'should not create new answer' do
        expect { post_invalid_answer }.not_to change { Answer.count }
      end

      it 'should render question show template' do
        post_invalid_answer
        expect(response).to render_template 'questions/show'
      end
    end
  end

end
