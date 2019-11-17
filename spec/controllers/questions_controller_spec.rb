require 'rails_helper'

RSpec.describe QuestionsController, type: :controller do
  let(:user) { create :user }

  describe 'GET #index' do
    it 'should render index view' do
      get :index
      expect(response).to render_template :index
    end
  end

  describe 'GET #new' do
    before { login(user) }

    it 'should render new view' do
      get :new
      expect(response).to render_template :new
    end
  end

  describe 'POST #create' do
    before { login(user) }

    context 'with valid params' do
      def post_question
        post :create, params: { question: attributes_for(:question) }
      end

      it 'should create new question' do
        expect { post_question }.to change { Question.count }.by(1)
      end
      it 'should set questions user attribute to current user' do
        post_question
        expect(Question.last.user).to eq user
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
    let(:question) { create :question, user: user }
    before { get :show, params: { id: question } }

    it 'should render show' do
      expect(response).to render_template :show
    end
  end

  describe 'DELETE #destroy' do
    let(:question) { create :question, user: user }

    before { login(user) }
    before { delete :destroy, params: { id: question } }

    it 'should destroy question' do
      expect(Question.all).not_to include(question)
    end

    it 'should redirect to questions_path' do
      expect(response).to redirect_to questions_path
    end
  end

end
