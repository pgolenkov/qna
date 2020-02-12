require 'rails_helper'

RSpec.describe Link, type: :model do
  it { should belong_to(:linkable) }
  it { should validate_presence_of :name }
  it { should validate_presence_of :url }
  it { is_expected.to validate_url_of(:url) }

  let(:question) { create :question }
  let(:link) { create :link, linkable: question }
  let(:gist_url) { 'https://gist.github.com/pashex/9b698d35948fe219a6d7441450053624' }

  describe '#gist?' do
    it 'should return false if url of link is not github gist' do
      expect(link).not_to be_gist
    end

    it 'should return true if url of link is github gist' do
      link.url = gist_url
      expect(link).to be_gist
    end
  end

  describe '#gist_raw' do
    it 'should return nil if url of link is not github gist' do
      expect(link.gist_raw).to be_nil
    end

    it 'should return gist raw if url of link is github gist' do
      link.url = gist_url
      expect(link.gist_raw).to eq 'My test gist'
    end
  end
end
