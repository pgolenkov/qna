require 'rails_helper'

RSpec.describe AnswersController, type: :controller do
  let(:question) { create :question }
  let(:user) { create :user }

  describe 'POST #create' do
    def post_answer
      post :create, params: { question_id: question.id, answer: attributes_for(:answer) }
    end

    describe 'by authenticated user' do
      before { login(user) }

      context 'with valid params' do
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

    describe 'by unauthenticated user' do
      it 'should not create new answer' do
        expect { post_answer }.not_to change { Answer.count }
      end
      it 'should redirect to new user session path' do
        post_answer
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:question) { create :question }
    let!(:answer) { create :answer, question: question, user: user }
    let!(:another_answer) { create :answer, question: question }

    def destroy_answer(answer)
      delete :destroy, params: { question_id: answer.question, id: answer }
    end

    describe 'by authenticated user' do
      before { login(user) }

      describe 'for own answer' do
        before { destroy_answer(answer) }

        it 'should destroy answer' do
          expect(Answer.all).not_to include(answer)
        end

        it 'should redirect to question_path' do
          expect(response).to redirect_to question_path(question)
        end
      end

      describe 'for another`s answer' do
        before { destroy_answer(another_answer) }

        it 'should not delete answer' do
          expect(Answer.all).to include(another_answer)
        end

        it 'should redirect to question_path' do
          expect(response).to redirect_to question_path(question)
        end
      end
    end

    describe 'by unauthenticated user' do
      before { destroy_answer(answer) }

      it 'should not delete any answer' do
        expect(Answer.all).to include(answer)
      end

      it 'should redirect to new user session path' do
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

end
