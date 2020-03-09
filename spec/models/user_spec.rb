require 'rails_helper'

RSpec.describe User, type: :model do
  it { should have_many(:questions).dependent(:destroy) }
  it { should have_many(:answers).dependent(:destroy) }
  it { should have_many(:comments).dependent(:destroy) }
  it { should have_many(:authorizations).dependent(:destroy) }
  it { should have_many(:awards) }

  it { should validate_presence_of :email }
  it { should validate_presence_of :password }


  describe '.find_for_oauth' do
    let!(:user) { create :user }
    let(:base_auth) { OmniAuth::AuthHash.new(provider: 'github', uid: '123456') }

    context 'user already has authorization' do
      before { user.authorizations.create(provider: base_auth.provider, uid: base_auth.uid) }

      it 'returns the user' do
        expect(User.find_for_oauth(base_auth)).to eq user
      end
    end

    context 'user has no authorization' do
      let(:auth) { base_auth.merge(info: { email: user.email }) }

      context 'user exists' do
        it 'does not create new user' do
          expect { User.find_for_oauth(auth) }.not_to change(User, :count)
        end
        it 'should create authorization for user' do
          expect { User.find_for_oauth(auth) }.to change(user.authorizations, :count).by(1)
        end
        it 'should create authorization with provider and uid' do
          user = User.find_for_oauth(auth)
          authorization = user.authorizations.order(:id).last
          expect(authorization.provider).to eq auth.provider
          expect(authorization.uid).to eq auth.uid
        end

        it 'returns the user' do
          expect(User.find_for_oauth(auth)).to eq user
        end
      end

      context 'user does not exist' do
        let(:auth) { base_auth.merge(info: { email: 'newuser@email.com' }) }

        it 'does create new user' do
          expect { User.find_for_oauth(auth) }.to change(User, :count).by(1)
        end

        it 'returns new user' do
          expect(User.find_for_oauth(auth)).to be_a(User)
        end

        it 'fills email for new user' do
          user = User.find_for_oauth(auth)
          expect(user.email).to eq auth.info.email
        end

        it 'should create authorization for user' do
          user = User.find_for_oauth(auth)
          expect(user.authorizations).not_to be_empty
        end

        it 'should create authorization with provider and uid' do
          user = User.find_for_oauth(auth)
          authorization = user.authorizations.order(:id).last
          expect(authorization.provider).to eq auth.provider
          expect(authorization.uid).to eq auth.uid
        end
      end
    end
  end

  describe '#author?' do
    let(:user) { create :user }
    let(:question) { create :question, user: user }
    let(:another_question) { create :question }

    let(:answer) { create :answer, question: another_question, user: user }
    let(:another_answer) { create :answer, question: question }

    it 'should return true if user is an author of question' do
      expect(user).to be_author(question)
    end

    it 'should return false if user is not an author of question' do
      expect(user).not_to be_author(another_question)
    end

    it 'should return true if user is an author of answer' do
      expect(user).to be_author(answer)
    end

    it 'should return false if user is not an author of answer' do
      expect(user).not_to be_author(another_answer)
    end
  end
end
