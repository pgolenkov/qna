require 'rails_helper'

RSpec.describe LinksController, type: :controller do
  let(:user) { create :user }

  describe 'DELETE #destroy' do
    context 'question link' do
      let(:question) { create :question, user: user }
      let(:link) { create :link, linkable: question }
      let(:another_question) { create :question }
      let(:another_question_link) { create :link, linkable: another_question }

      subject { delete :destroy, params: { id: link, format: :js } }

      describe 'by authenticated user' do
        before { login(user) }

        context 'his question' do
          it 'should remove link from question' do
            expect(question.links).to eq [link]
            subject
            expect(question.links.reload).to be_empty
          end

          it { should render_template(:destroy) }
        end

        context 'another user`s question' do
          subject! { delete :destroy, params: { id: another_question_link, format: :js } }

          it 'should not remove link from question' do
            expect(another_question.links).to eq [another_question_link]
          end

          it 'should return forbidden status' do
            expect(response).to have_http_status(:forbidden)
          end
        end
      end

      describe 'by unauthenticated user' do
        before { subject }

        it 'should not remove link from question' do
          expect(question.links).to eq [link]
        end

        it 'should return unauthorized status' do
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end

    context 'answer link' do
      let(:answer) { create :answer, user: user }
      let(:link) { create :link, linkable: answer }
      let(:another_answer) { create :answer }
      let(:another_answer_link) { create :link, linkable: another_answer }

      subject { delete :destroy, params: { id: link, format: :js } }

      describe 'by authenticated user' do
        before { login(user) }

        context 'his answer' do
          it 'should remove link from answer' do
            expect(answer.links).to eq [link]
            subject
            expect(answer.links.reload).to be_empty
          end

          it { should render_template(:destroy) }
        end

        context 'another user`s answer' do
          subject! { delete :destroy, params: { id: another_answer_link, format: :js } }

          it 'should not remove link from answer' do
            expect(another_answer.links).to eq [another_answer_link]
          end

          it 'should return forbidden status' do
            expect(response).to have_http_status(:forbidden)
          end
        end
      end

      describe 'by unauthenticated user' do
        before { subject }

        it 'should not remove link from answer' do
          expect(answer.links).to eq [link]
        end

        it 'should return unauthorized status' do
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
  end
end
