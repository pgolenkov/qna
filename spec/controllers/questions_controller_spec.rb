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
    subject { post :create, params: { question: attributes_for(:question) } }

    describe 'by authenticated user' do
      before { login(user) }

      context 'with valid params' do
        it 'should create new question' do
          expect { subject }.to change { Question.count }.by(1)
        end
        describe do
          before { subject }
          it 'should set questions user attribute to current user' do
            expect(Question.last.user).to eq user
          end
          it { should redirect_to(question_path(Question.last)) }
        end
      end

      context 'with invalid params' do
        subject { post :create, params: { question: attributes_for(:question, :invalid) } }
        it 'should not create new question' do
          expect { subject }.not_to change { Question.count }
        end
        it { should render_template(:new) }
      end
    end

    describe 'by unauthenticated user' do
      it 'should not create new question' do
        expect { subject }.not_to change { Question.count }
      end
      it { should redirect_to(new_user_session_path) }
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
    let!(:question) { create :question, user: user }
    let!(:another_question) { create :question }

    subject { delete :destroy, params: { id: question } }
    describe 'by authenticated user' do
      before { login(user) }

      describe 'for own question' do
        it 'should destroy question' do
          expect { subject }.to change { Question.count }.by(-1)
          expect(Question).not_to exist(question.id)
        end

        it { should redirect_to(questions_path) }
      end

      describe 'for another`s question' do
        subject! { delete :destroy, params: { id: another_question } }

        it 'should not delete another question' do
          expect { subject }.not_to change { Question.count }
          expect(Question).to exist(another_question.id)
        end

        it { should redirect_to(questions_path) }
      end
    end

    describe 'by unauthenticated user' do
      it 'should not delete any question' do
        expect { subject }.not_to change { Question.count }
        expect(Question).to exist(question.id)
      end

      it { should redirect_to(new_user_session_path) }
    end
  end
end
