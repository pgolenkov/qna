require 'rails_helper'

RSpec.describe Services::Notification do
  describe '#new_answer' do
    let!(:user) { create :user }
    let(:question) { create :question }
    let(:question_owner) { question.user }
    let(:answer) { create :answer, question: question }

    it 'sends new answer notification mail to owner of question only' do
      expect(NotificationMailer).to receive(:new_answer).with(question_owner, answer).and_call_original
      expect(NotificationMailer).not_to receive(:new_answer).with(user, answer)
      subject.new_answer(answer)
    end
  end
end
