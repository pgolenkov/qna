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
    let(:last_question) { Question.order(:created_at).last }

    describe 'by authenticated user' do
      before { login(user) }

      context 'with valid params' do
        it 'should create new question' do
          expect { subject }.to change { Question.count }.by(1)
        end
        describe do
          before { subject }

          it 'should set questions user attribute to current user' do
            expect(last_question.user).to eq user
          end
          it { should redirect_to(question_path(last_question)) }
        end

        it 'should broadcast new question to channel' do
          expect { subject }.to have_broadcasted_to("questions").with(last_question)
        end
      end

      context 'with attached files' do
        it 'should attach files to question' do
          post :create, params: { question: { title: 'Title', body: 'Body', files: [fixture_file_upload('spec/spec_helper.rb')]} }
          expect(last_question.files).to be_attached
        end
      end

      context 'with links' do
        context 'where links is valid' do
          it 'should add links to question' do
            post :create, params: { question: { title: 'Title', body: 'Body', links_attributes: { 0 => { name: 'Google', url: 'https://google.com' }, 1 => { name: 'Yandex', url: 'https://yandex.ru' } } } }
            expect(last_question.links.pluck(:name).sort).to eq ['Google', 'Yandex']
            expect(last_question.links.pluck(:url).sort).to eq ['https://google.com', 'https://yandex.ru']
          end
        end
        context 'where links is not valid' do
          subject do
            post :create, params: { question: { title: 'Title', body: 'Body', links_attributes: { 0 => { url: 'https://google.com' } } } }
          end

          it 'should not create new question' do
            expect { subject }.not_to change { Question.count }
          end

          it 'should not broadcast to channel' do
            expect { subject }.not_to have_broadcasted_to("questions")
          end

          it { should render_template(:new) }
        end
      end

      context 'with award' do
        context 'where award is valid' do
          it 'should add award to question' do
            post :create, params: { question: { title: 'Title', body: 'Body', award_attributes: { name: 'Award name', image: fixture_file_upload('public/apple-touch-icon.png') } } }
            expect(last_question.award.name).to eq 'Award name'
            expect(last_question.award.image).to be_attached
            expect(last_question.award.image.filename.to_s).to eq 'apple-touch-icon.png'
          end
        end
        context 'where award is not valid' do
          subject do
            post :create, params: { question: { title: 'Title', body: 'Body', award_attributes: { name: 'Award name', image: fixture_file_upload('spec/spec_helper.rb') } } }
          end

          it 'should not create new question' do
            expect { subject }.not_to change { Question.count }
          end

          it 'should not broadcast to channel' do
            expect { subject }.not_to have_broadcasted_to("questions")
          end

          it { should render_template(:new) }
        end

        context 'where award name is blank' do
          subject! do
            post :create, params: { question: { title: 'Title', body: 'Body', award_attributes: { name: ' ', image: fixture_file_upload('public/apple-touch-icon.png') } } }
          end
          it 'should create new question without award' do
            expect(last_question.award).to be_nil
          end
          it { should redirect_to(question_path(last_question)) }
        end
      end

      context 'with invalid params' do
        subject { post :create, params: { question: attributes_for(:question, :invalid) } }
        it 'should not create new question' do
          expect { subject }.not_to change { Question.count }
        end

        it 'should not broadcast to channel' do
          expect { subject }.not_to have_broadcasted_to("questions")
        end

        it { should render_template(:new) }
      end
    end

    describe 'by unauthenticated user' do
      it 'should not create new question' do
        expect { subject }.not_to change { Question.count }
      end

      it 'should not broadcast to channel' do
        expect { subject }.not_to have_broadcasted_to("questions")
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

  describe 'GET #show' do
    include_context :gon

    let(:question) { create :question, user: user }
    before { get :show, params: { id: question } }

    it 'should render show' do
      expect(response).to render_template :show
    end

    it 'should set gon question id' do
      expect(gon['question_id']).to eq question.id
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

        it 'should return forbidden status' do
          expect(response).to have_http_status(:forbidden)
        end
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
