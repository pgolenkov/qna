require 'rails_helper'

RSpec.describe Ability do
  subject { Ability.new(user) }

  describe 'for guest' do
    let(:user) { nil }

    it { should be_able_to :read, Question }
    it { should be_able_to :read, Answer }
    it { should be_able_to :read, Comment }

    it { should_not be_able_to :manage, :all }
  end

  describe 'for user' do
    let(:user) { create :user }

    let(:user_question) { create :question, user: user }
    let(:other_question) { create :question }

    let(:user_answer) { create :answer, user: user }
    let(:other_answer) { create :answer }

    it { should_not be_able_to :manage, :all }
    it { should be_able_to :read, :all }

    describe 'create abilities' do
      it { should be_able_to :create, Question }
      it { should be_able_to :create, Answer }
      it { should be_able_to :create, Comment }
      it { should be_able_to :create, Vote }
    end

    describe 'update abilities' do
      it { should be_able_to :update, user_question }
      it { should_not be_able_to :update, other_question }

      it { should be_able_to :update, user_answer }
      it { should_not be_able_to :update, other_answer }
    end

    describe 'destroy abilities' do
      let(:user_question_with_file) { create :question, user: user, files: [fixture_file_upload('spec/rails_helper.rb')] }
      let(:other_question_with_file) { create :question, files: [fixture_file_upload('spec/rails_helper.rb')] }
      let(:user_answer_with_file) { create :answer, user: user, files: [fixture_file_upload('spec/rails_helper.rb')] }
      let(:other_answer_with_file) { create :answer, files: [fixture_file_upload('spec/rails_helper.rb')] }

      it { should be_able_to :destroy, user_question }
      it { should_not be_able_to :destroy, other_question }

      it { should be_able_to :destroy, user_answer }
      it { should_not be_able_to :destroy, other_answer }

      it { should be_able_to :destroy, create(:link, linkable: user_question) }
      it { should_not be_able_to :destroy, create(:link, linkable: other_question) }

      it { should be_able_to :destroy, create(:link, linkable: user_answer) }
      it { should_not be_able_to :destroy, create(:link, linkable: other_answer) }

      it { should be_able_to :destroy, user_question_with_file.files.first }
      it { should_not be_able_to :destroy, other_question_with_file.files.first }

      it { should be_able_to :destroy, user_answer_with_file.files.first }
      it { should_not be_able_to :destroy, other_answer_with_file.files.first }

      it { should be_able_to :destroy, create(:vote, user: user) }
      it { should_not be_able_to :destroy, create(:vote) }
    end

    describe 'make best answer abilities' do
      it { should be_able_to :make_best, create(:answer, question: user_question) }
      it { should_not be_able_to :make_best, create(:answer, question: other_question) }
      it { should_not be_able_to :make_best, create(:answer, user: user, question: other_question) }
    end
  end

end
