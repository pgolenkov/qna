require 'rails_helper'

RSpec.describe Question, type: :model do
  it { should have_many(:answers).order(best: :desc).dependent(:destroy) }
  it { should belong_to(:user) }

  it { should validate_presence_of :title }
  it { should validate_presence_of :body }

  it { should validate_uniqueness_of :title }

  let(:question) { create :question }
  let(:answers) { create_list :answer, 2, question: question }

  describe '#best_answer' do
    it 'should return nil if no best answer of question' do
      expect(question.best_answer).to be_nil
    end

    it 'should return the best answer of question' do
      answers.last.best!
      expect(question.best_answer).to eq answers.last
    end
  end

  describe 'the best answer of question answers' do
    before { answers.last.best! }

    it 'should be on the first position' do
      expect(question.answers.first).to eq answers.last
    end
  end

  it 'have many attached files' do
    expect(question.files).to be_an_instance_of(ActiveStorage::Attached::Many)
  end
end
