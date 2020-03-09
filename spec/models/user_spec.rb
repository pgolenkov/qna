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
    let(:auth) { OmniAuth::AuthHash.new(provider: 'github', uid: '123456') }
    let(:service) { double('Services::FindForOauth') }

    it 'calls Services::FindForOauth' do
      expect(Services::FindForOauth).to receive(:new).with(auth).and_return(service)
      expect(service).to receive(:call)
      User.find_for_oauth(auth)
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
