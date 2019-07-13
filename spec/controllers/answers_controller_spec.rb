require 'rails_helper'

RSpec.describe AnswersController, type: :controller do
  let(:question) { create :question }

  describe 'GET #new' do
    before { get :new, params: { question_id: question.id } }

    it 'should render new template' do
      expect(response).to render_template :new
    end
    it 'should assign answer to question' do
      expect(assigns(:answer).question).to eq question
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      def post_answer
        post :create, params: { question_id: question.id, answer: attributes_for(:answer) }
      end

      it 'should create new answer' do
        expect { post_answer }.to change { Answer.count }.by(1)
      end
      it 'should assign answer to question' do
        post_answer
        expect(assigns(:answer).question).to eq question
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

      it 'should render new template' do
        post_invalid_answer
        expect(response).to render_template :new
      end
    end
  end

end
