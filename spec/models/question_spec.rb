require 'rails_helper'

RSpec.describe Question, type: :model do
  it { should have_many(:answers).order(best: :desc).dependent(:destroy) }
  it { should belong_to(:user) }

  it { should validate_presence_of :title }
  it { should validate_presence_of :body }

  it { should validate_uniqueness_of :title }

  describe '#best_answer' do
    let(:question) { create :question }
    let(:answers) { create_list :answer, 2, question: question }

    it 'should return nil if no best answer of question' do
      expect(question.best_answer).to be_nil
    end

    it 'should return the best answer of question' do
      answers.last.best!
      expect(question.best_answer).to eq answers.last
    end
  end
end
