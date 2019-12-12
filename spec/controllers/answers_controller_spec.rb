require 'rails_helper'

RSpec.describe AnswersController, type: :controller do
  let(:question) { create :question }
  let(:user) { create :user }

  describe 'POST #create' do
    subject { post :create, params: { question_id: question.id, answer: attributes_for(:answer) }, format: :js }

    describe 'by authenticated user' do
      before { login(user) }

      context 'with valid params' do
        it 'should create new answer for question' do
          expect { subject }.to change { question.answers.count }.by(1)
        end
        it { should render_template(:create) }
      end
      context 'with invalid params' do
        subject { post :create, params: { question_id: question.id, answer: attributes_for(:answer, :invalid) }, format: :js }

        it 'should not create new answer' do
          expect { subject }.not_to change { Answer.count }
        end

        it { should render_template(:create) }
      end
    end

    describe 'by unauthenticated user' do
      it 'should not create new answer' do
        expect { subject }.not_to change { Answer.count }
      end
      it 'should return unauthorized status' do
        subject
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:question) { create :question }
    let!(:answer) { create :answer, question: question, user: user }
    let!(:another_answer) { create :answer, question: question }

    subject { delete :destroy, params: { question_id: answer.question, id: answer } }

    describe 'by authenticated user' do
      before { login(user) }

      describe 'for own answer' do
        it 'should destroy answer' do
          expect { subject }.to change { Answer.count }.by(-1)
          expect(Answer).not_to exist(answer.id)
        end

        it { should redirect_to(question_path(question)) }
      end

      describe 'for another`s answer' do
        subject { delete :destroy, params: { question_id: another_answer.question, id: another_answer } }

        it 'should not delete answer' do
          expect { subject }.not_to change { Answer.count }
          expect(Answer).to exist(another_answer.id)
        end

        it { should redirect_to(question_path(question)) }
      end
    end

    describe 'by unauthenticated user' do
      it 'should not delete any answer' do
        expect { subject }.not_to change { Answer.count }
        expect(Answer).to exist(answer.id)
      end

      it { should redirect_to(new_user_session_path) }
    end
  end

end
