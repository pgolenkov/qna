require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe 'GET #edit' do
    let!(:user) { create :user }

    describe 'with valid authorization params' do
      let!(:authorization) { create :authorization, user: user }
      before { get :edit, params: { provider: authorization.provider, uid: authorization.uid } }

      it 'should render edit view' do
        expect(response).to render_template :edit
      end

      it 'should initialize user instance var by authentication' do
        expect(assigns(:user)).to eq user
      end
    end

    describe 'with invalid authorization params' do
      it 'should raise not found error' do
        expect { get :edit, params: { provider: 'provider', uid: 'uid' } }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'PATCH #update' do
    let!(:user) { create :user }

    describe 'with valid authorization params and email' do
      let!(:authorization) { create :authorization, user: user }
      subject { patch :update, params: { provider: authorization.provider, uid: authorization.uid, email: 'new@email.com' } }

      it 'should update user email' do
        subject
        expect(user.reload.email).to eq 'new@email.com'
      end

      it { should redirect_to(root_path) }

      it 'should send confirmation email' do
        expect { subject }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end

    describe 'with valid authorization params and invalid email' do
      let!(:authorization) { create :authorization, user: user }
      subject { patch :update, params: { provider: authorization.provider, uid: authorization.uid, email: '' } }

      it 'should not update user email' do
        subject
        expect(user.reload.email).to eq user.email
      end

      it { should render_template(:edit) }

      it 'should not send confirmation email' do
        expect { subject }.not_to change { ActionMailer::Base.deliveries.count }
      end
    end

    describe 'with invalid authorization params' do
      it 'should raise not found error' do
        expect { get :edit, params: { provider: 'provider', uid: 'uid' } }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'should not send confirmation email' do
        expect { subject }.not_to change { ActionMailer::Base.deliveries.count }
      end
    end
  end


end
