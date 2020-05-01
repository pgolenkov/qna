require 'rails_helper'

RSpec.describe Services::DailyDigest do
  let(:users) { create_list :user, 2 }

  it 'sends daily digest for all users' do
    users.each do |user|
      expect(DailyDigestMailer).to receive(:digest).with(user).and_call_original
    end
    subject.send_digest
  end
end
