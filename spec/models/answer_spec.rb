require 'rails_helper'

RSpec.describe Answer, type: :model do
  it { should belong_to :question }
  it { should belong_to :user }
  it { should have_many(:links).dependent(:destroy) }
  it { should accept_nested_attributes_for(:links) }

  it { should validate_presence_of :body }

  describe 'validates uniqueness of best answer for one question' do
    subject { create :answer, :best }
    it { should validate_uniqueness_of(:question_id).scoped_to(:best) }
  end

  describe 'doesn`t validate uniqueness of not best answer for one question' do
    subject { create :answer }
    it { should_not validate_uniqueness_of(:question_id).scoped_to(:best) }
  end

  describe '#best!' do
    let(:question) { create :question }
    let(:answers) { create_list :answer, 2, question: question }
    let(:other_question_best_answer) { create :answer, :best }

    before { answers.first.best! }

    it 'should set the answer the best' do
      expect(answers.first.reload).to be_best
    end

    it 'should reset best attribute for other answers of question' do
      answers.second.best!
      expect(answers.first.reload).not_to be_best
    end

    it 'should not reset best attribute for answers of other question' do
      expect(other_question_best_answer.reload).to be_best
    end

    context 'when question has an award' do
      let!(:award) { create :award, question: question }
      before { answers.second.best! }

      it 'should give award to the user of the best answer' do
        expect(answers.second.user.awards).to eq [award]
      end

      context 'when another user has award of this question' do
        it 'should take away award from another user' do
          expect(answers.second.user.awards).to eq [award]
          answers.first.best!
          expect(answers.second.user.awards.reload).to eq []
        end
      end
    end
  end

  it 'have many attached files' do
    expect(subject.files).to be_an_instance_of(ActiveStorage::Attached::Many)
  end
end
