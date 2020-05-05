require 'rails_helper'

RSpec.describe SubscriptionsController, type: :controller do
  describe 'POST #create' do
    let!(:question) { create :question }

    subject { post :create, params: { subscribable_type: 'Question', subscribable_id: question.id }, format: :js }

    context 'for authenticated user' do
      let(:user) { create :user }

      before { login(user) }

      it 'creates new subscription for question' do
        expect { subject }.to change { question.subscriptions.count }.by(1)
      end

      it 'creates new subscription for user' do
        expect { subject }.to change { user.subscriptions.count }.by(1)
      end

      it { should render_template(:create) }

      context 'if subscription is present for user and question' do
        before { question.subscriptions.create!(user: user) }

        it 'should not create new subscription' do
          expect { subject }.not_to change(Subscription, :count)
        end

        it { should render_template(:create) }
      end
    end

    context 'by unauthenticated user' do
      it 'should not create new subscription' do
        expect { subject }.not_to change(Subscription, :count)
      end

      it 'returns unauthorized status' do
        subject
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:question) { create :question }

    subject { delete :destroy, params: { subscribable_type: 'Question', subscribable_id: question.id }, format: :js }

    context 'for authenticated user' do
      let(:user) { create :user }

      before { login(user) }

      context 'if subscription is present for user and question' do
        before { question.subscriptions.create!(user: user) }

        it 'destroys the subscription for question' do
          expect { subject }.to change { question.subscriptions.count }.by(-1)
        end

        it 'destroys the subscription for user' do
          expect { subject }.to change { user.subscriptions.count }.by(-1)
        end

        it { should render_template(:destroy) }
      end

      context 'if no subscriptions for user and question' do
        it 'should not change subscriptions count' do
          expect { subject }.not_to change(Subscription, :count)
        end

        it { should render_template(:destroy) }
      end
    end

    context 'by unauthenticated user' do
      it 'should not change subscriptions count' do
        expect { subject }.not_to change(Subscription, :count)
      end

      it 'returns unauthorized status' do
        subject
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
