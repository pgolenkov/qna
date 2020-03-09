require 'rails_helper'

RSpec.describe Services::FindForOauth do
  let!(:user) { create :user }
  let(:base_auth) { OmniAuth::AuthHash.new(provider: 'github', uid: '123456') }

  subject { Services::FindForOauth.new(auth) }

  context 'user already has authorization' do
    let(:auth) { base_auth }

    before { user.authorizations.create(provider: auth.provider, uid: auth.uid) }

    it 'returns the user' do
      expect(subject.call).to eq user
    end
  end

  context 'user has no authorization' do
    let(:auth) { base_auth.merge(info: { email: user.email }) }

    context 'user exists' do
      it 'does not create new user' do
        expect { subject.call }.not_to change(User, :count)
      end
      it 'should create authorization for user' do
        expect { subject.call }.to change(user.authorizations, :count).by(1)
      end
      it 'should create authorization with provider and uid' do
        user = subject.call
        last_authorization = user.authorizations.order(:id).last
        expect(last_authorization.provider).to eq auth.provider
        expect(last_authorization.uid).to eq auth.uid
      end

      it 'returns the user' do
        expect(subject.call).to eq user
      end
    end

    context 'user does not exist' do
      let(:auth) { base_auth.merge(info: { email: 'newuser@email.com' }) }

      it 'does create new user' do
        expect { subject.call }.to change(User, :count).by(1)
      end

      it 'returns new user' do
        expect(subject.call).to be_a(User)
      end

      it 'fills email for new user' do
        expect(subject.call.email).to eq auth.info.email
      end

      it 'should create authorization for user' do
        user = subject.call
        expect(user.authorizations).not_to be_empty
      end

      it 'should create authorization with provider and uid' do
        user = subject.call
        last_authorization = user.authorizations.order(:id).last
        expect(last_authorization.provider).to eq auth.provider
        expect(last_authorization.uid).to eq auth.uid
      end
    end
  end

end
