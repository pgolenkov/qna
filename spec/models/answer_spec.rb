require 'rails_helper'

RSpec.describe Answer, type: :model do
  it { should belong_to :question }
  it { should belong_to :user }

  it { should validate_presence_of :body }

  describe 'validates uniqueness of best answer for one question' do
    let(:question) { create :question }
    let(:answers) { create_list :answer, 2, question: question }
    let(:other_question_answer) { create :answer }

    before { answers.first.update(best: true) }

    context 'answers for one question' do
      before { answers.second.best = true }

      it 'second answer with best attibute is not to be valid' do
        expect(answers.first).to be_valid
        expect(answers.second).not_to be_valid
      end
    end

    context 'answers for different questions' do
      before { other_question_answer.best = true }

      it 'answer for other question with best attibute is to be valid' do
        expect(other_question_answer).to be_valid
      end
    end
  end
end
