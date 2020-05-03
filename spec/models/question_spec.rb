require 'rails_helper'

RSpec.describe Question, type: :model do
  subject { build :question }

  it { should have_many(:answers).order(best: :desc).dependent(:destroy) }
  it { should belong_to(:user) }
  it_behaves_like "linkable"
  it_behaves_like "votable"
  it_behaves_like "commentable"
  it_behaves_like "subscribable"

  it { should have_one(:award).dependent(:destroy) }
  it { should accept_nested_attributes_for(:award) }

  it { should validate_presence_of :title }
  it { should validate_presence_of :body }

  it { should validate_uniqueness_of :title }

  let(:answers) { create_list :answer, 2, question: subject }

  describe '#best_answer' do
    it 'should return nil if no best answer of question' do
      expect(subject.best_answer).to be_nil
    end

    it 'should return the best answer of question' do
      answers.last.best!
      expect(subject.best_answer).to eq answers.last
    end
  end

  describe 'the best answer of question answers' do
    before { answers.last.best! }

    it 'should be on the first position' do
      expect(subject.answers.first).to eq answers.last
    end
  end

  it 'have many attached files' do
    expect(subject.files).to be_an_instance_of(ActiveStorage::Attached::Many)
  end

  describe '#subscribe_author' do
    it "create subscription of author to question after create" do
      subject.save
      expect(subject.user).to be_subscribed(subject)
    end
  end
end
