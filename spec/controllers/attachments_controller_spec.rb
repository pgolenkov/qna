require 'rails_helper'

RSpec.describe AttachmentsController, type: :controller do
  let(:user) { create :user }

  describe 'DELETE #destroy' do
    context 'answer attachment' do
      let!(:answer) { create :answer, user: user, files: [fixture_file_upload('spec/spec_helper.rb')] }
      let!(:another_answer) { create :answer, files: [fixture_file_upload('spec/rails_helper.rb')] }

      subject { delete :destroy, params: { id: answer.files.first, format: :js } }

      describe 'by authenticated user' do
        before { login(user) }

        context 'his answer' do
          it 'should remove file from answer' do
            subject
            expect(answer.reload.files).not_to be_attached
          end

          it { should render_template(:destroy) }
        end

        context 'another user`s answer' do
          subject! { delete :destroy, params: { id: another_answer.files.first, format: :js } }

          it 'should not remove file from question' do
            expect(another_answer.reload.files).to be_attached
          end

          it 'should return forbidden status' do
            expect(response).to have_http_status(:forbidden)
          end
        end
      end

      describe 'by unauthenticated user' do
        before { subject }

        it 'should not remove file from answer' do
          expect(answer.reload.files).to be_attached
        end

        it 'should return unauthorized status' do
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end

    context 'question attachment' do
      let!(:question) { create :question, user: user, files: [fixture_file_upload('spec/spec_helper.rb')] }
      let!(:another_question) { create :question, files: [fixture_file_upload('spec/rails_helper.rb')] }

      subject { delete :destroy, params: { id: question.files.first, format: :js } }

      describe 'by authenticated user' do
        before { login(user) }

        context 'his question' do
          it 'should remove file from question' do
            subject
            expect(question.reload.files).not_to be_attached
          end

          it { should render_template(:destroy) }
        end

        context 'another user`s question' do
          subject! { delete :destroy, params: { id: another_question.files.first, format: :js } }

          it 'should not remove file from question' do
            expect(another_question.reload.files).to be_attached
          end

          it 'should return forbidden status' do
            expect(response).to have_http_status(:forbidden)
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
  end

end
