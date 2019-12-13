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

  describe 'PATCH #update' do
    let!(:answer) { create :answer, question: question, user: user }
    subject { patch :update, params: { id: answer, answer: { body: 'Edited answer'} }, format: :js }

    describe 'by authenticated user' do
      before { login(user) }

      context 'his answer with valid params' do
        it 'should change answer for question' do
          subject
          expect(answer.reload.body).to eq 'Edited answer'
        end
        it { should render_template(:update) }
      end

      context 'his answer with invalid params' do
        subject { patch :update, params: { id: answer, answer: attributes_for(:answer, :invalid) }, format: :js }

        it 'should not change answer' do
          expect { subject }.to_not change(answer, :body)
        end

        it { should render_template(:update) }
      end

      context "another user's answer" do
        let!(:another_answer) { create :answer }
        subject { patch :update, params: { id: another_answer, answer: { body: 'Edited answer'} }, format: :js }
        before { subject }

        it 'should not change answer' do
          expect { subject }.to_not change(another_answer, :body)
        end

        it 'should return forbidden status' do
          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    describe 'by unauthenticated user' do
      before { subject }

      it 'should not change answer' do
        expect { subject }.to_not change(answer, :body)
      end

      it 'should return unauthorized status' do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:question) { create :question }
    let!(:answer) { create :answer, question: question, user: user }
    let!(:another_answer) { create :answer, question: question }

    subject { delete :destroy, params: { question_id: answer.question, id: answer }, format: :js }

    describe 'by authenticated user' do
      before { login(user) }

      describe 'for own answer' do
        it 'should destroy answer' do
          expect { subject }.to change { Answer.count }.by(-1)
          expect(Answer).not_to exist(answer.id)
        end

        it { should render_template(:destroy) }
      end

      describe 'for another`s answer' do
        subject { delete :destroy, params: { question_id: another_answer.question, id: another_answer }, format: :js }

        it 'should not delete answer' do
          expect { subject }.not_to change { Answer.count }
          expect(Answer).to exist(another_answer.id)
        end

        it 'should return forbidden status' do
          subject
          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    describe 'by unauthenticated user' do
      it 'should not delete any answer' do
        expect { subject }.not_to change { Answer.count }
        expect(Answer).to exist(answer.id)
      end

      it 'should return unauthorized status' do
        subject
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

end
