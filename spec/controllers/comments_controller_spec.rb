require 'rails_helper'

RSpec.describe CommentsController, type: :controller do
  let(:user) { create :user }

  describe 'POST #create' do
    let(:last_comment) { Comment.order(:created_at).last }

    context 'for question' do
      let(:question) { create :question }

      subject { post :create, params: { commentable_type: question.class, commentable_id: question.id, comment: { body: 'My comment'} }, format: :js }

      describe 'by authenticated user' do
        before { login(user) }

        context 'with valid params' do
          it 'should create new comment for question' do
            expect { subject }.to change { question.comments.count }.by(1)
          end
          it { should render_template(:create) }

          it 'should broadcast new comment to channel' do
            expect { subject }.to have_broadcasted_to("comments-#{question.id}").with(last_comment)
          end
        end

        context 'with invalid params' do
          subject { post :create, params: { commentable_type: question.class, commentable_id: question.id, comment: { body: ' '} }, format: :js }

          it 'should not create new comment' do
            expect { subject }.not_to change { Comment.count }
          end

          it { should render_template(:create) }
        end
      end

      describe 'by unauthenticated user' do
        it 'should not create new comment' do
          expect { subject }.not_to change { Comment.count }
        end
        it 'should return unauthorized status' do
          subject
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end

    context 'for answer' do
      let(:answer) { create :answer }

      subject { post :create, params: { commentable_type: answer.class, commentable_id: answer.id, comment: { body: 'My comment'} }, format: :js }

      describe 'by authenticated user' do
        before { login(user) }

        context 'with valid params' do
          it 'should create new comment for answer' do
            expect { subject }.to change { answer.comments.count }.by(1)
          end
          it { should render_template(:create) }

          it 'should broadcast new comment to channel' do
            expect { subject }.to have_broadcasted_to("comments-#{answer.question_id}").with(last_comment)
          end
        end

        context 'with invalid params' do
          subject { post :create, params: { commentable_type: answer.class, commentable_id: answer.id, comment: { body: ' '} }, format: :js }

          it 'should not create new comment' do
            expect { subject }.not_to change { Comment.count }
          end

          it { should render_template(:create) }
        end
      end

      describe 'by unauthenticated user' do
        it 'should not create new comment' do
          expect { subject }.not_to change { Comment.count }
        end
        it 'should return unauthorized status' do
          subject
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
  end
end
