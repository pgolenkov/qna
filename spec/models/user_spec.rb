require 'rails_helper'

RSpec.describe User, type: :model do
  it { should have_many(:questions).dependent(:destroy) }
  it { should have_many(:answers).dependent(:destroy) }

  it { should validate_presence_of :email }
  it { should validate_presence_of :password }

  describe '#author?' do
    let(:user) { create :user }
    let(:question) { create :question, user: user }
    let(:another_question) { create :question }

    let(:answer) { create :answer, question: another_question, user: user }
    let(:another_answer) { create :answer, question: question }

    it 'should return true if user is an author of question' do
      expect(user.author?(question)).to be_truthy
    end

    it 'should return false if user is not an author of question' do
      expect(user.author?(another_question)).to be_falsey
    end

    it 'should return true if user is an author of answer' do
      expect(user.author?(answer)).to be_truthy
    end

    it 'should return false if user is not an author of answer' do
      expect(user.author?(another_answer)).to be_falsey
    end
  end
end
