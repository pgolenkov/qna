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

      context 'with attached files' do
        it 'should attach files to question' do
          post :create, params: { question: { title: 'Title', body: 'Body', files: [fixture_file_upload('spec/spec_helper.rb')]} }
          expect(Question.last.files).to be_attached
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

  describe 'PATCH #update' do
    let!(:question) { create :question, user: user }
    subject { patch :update, params: { id: question, question: { title: 'Edited title', body: 'Edited body'} }, format: :js }

    describe 'by authenticated user' do
      before { login(user) }

      context 'his question with valid params' do
        it 'should change question' do
          subject
          expect(question.reload.title).to eq 'Edited title'
          expect(question.body).to eq 'Edited body'
        end
        it { should render_template(:update) }
      end

      context 'with attached files' do
        it 'should attach files to question' do
          patch :update, params: { id: question, question: { files: [fixture_file_upload('spec/spec_helper.rb')] } }, format: :js
          expect(question.reload.files).to be_attached
        end
      end

      context 'his question with invalid params' do
        subject { patch :update, params: { id: question, question: { title: '' } }, format: :js }

        it 'should not change question' do
          expect { subject }.to_not change(question, :title)
        end

        it { should render_template(:update) }
      end

      context "another user's question" do
        let!(:another_question) { create :question }
        subject { patch :update, params: { id: another_question, question: { title: 'Edited title' }, format: :js } }
        before { subject }

        it 'should not change question' do
          expect { subject }.to_not change(another_question, :title)
        end

        it 'should return forbidden status' do
          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    describe 'by unauthenticated user' do
      it 'should not change question`s title' do
        expect { subject }.to_not change(question, :title)
      end

      it 'should not change question`s body' do
        expect { subject }.to_not change(question, :body)
      end

      it 'should return unauthorized status' do
        subject
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PATCH #remove_file' do
    let!(:question) { create :question, user: user, files: [fixture_file_upload('spec/spec_helper.rb')] }
    let!(:another_question) { create :question, files: [fixture_file_upload('spec/rails_helper.rb')] }

    subject { patch :remove_file, params: { id: question, file_id: question.files.first.id, format: :js } }

    describe 'by authenticated user' do
      before { login(user) }

      context 'his question' do
        it 'should remove file from question' do
          subject
          expect(question.reload.files).not_to be_attached
        end

        it { should render_template(:remove_file) }
      end

      context 'another user`s question' do
        subject! { patch :remove_file, params: { id: another_question, file_id: another_question.files.first.id, format: :js } }

        it 'should not remove file from question' do
          expect(another_question.reload.files).to be_attached
        end

        it 'should return forbidden status' do
          expect(response).to have_http_status(:forbidden)
        end
      end

      context 'file of another question' do
        subject! { patch :remove_file, params: { id: question, file_id: another_question.files.first.id, format: :js } }

        it 'should not remove file from question' do
          expect(another_question.reload.files).to be_attached
        end

        it 'should return not found status' do
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    describe 'by unauthenticated user' do
      before { subject }

      it 'should not remove file from question' do
        expect(question.reload.files).to be_attached
      end

      it 'should return unauthorized status' do
        expect(response).to have_http_status(:unauthorized)
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
