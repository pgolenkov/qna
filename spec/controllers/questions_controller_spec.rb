require 'rails_helper'

RSpec.describe QuestionsController, type: :controller do
  describe 'GET #index' do
    it 'should render index view' do
      get :index
      expect(response).to render_template :index
    end
  end

  describe 'GET #new' do
    it 'should render new view' do
      get :new
      expect(response).to render_template :new
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      def post_question
        post :create, params: { question: attributes_for(:question) }
      end

      it 'should create new question' do
        expect { post_question }.to change { Question.count }.by(1)
      end
      it 'should redirect to created question' do
        post_question
        expect(response).to redirect_to Question.last
      end
    end

    context 'with invalid params' do
      it 'should not create new question' do
        expect { post :create, params: { question: attributes_for(:question, :invalid) } }.not_to change { Question.count }
      end
      it 'should render new view' do
        post :create, params: { question: attributes_for(:question, :invalid) }
        expect(response).to render_template :new
      end
    end
  end

  describe 'GET #show' do
    let(:question) { create :question }
    before { get :show, params: { id: question } }

    it 'should render show' do
      expect(response).to render_template :show
    end
  end

end
