RSpec.shared_examples "votable" do
  it { should have_many(:votes).dependent(:destroy) }

  describe '#rating' do
    let(:votable) { create described_class.to_s.underscore.to_sym }

    context 'when votable has not any votes' do
      it 'should return zero' do
        expect(votable.rating).to be_zero
      end
    end

    context 'when votable has some votes' do
      let!(:like_votes) { create_list :vote, 2, :like, votable: votable }
      let!(:dislike_votes) { create_list :vote, 1, :dislike, votable: votable }

      it 'should return difference between likes and dislikes' do
        expect(votable.rating).to eq 1
      end
    end
  end

  describe '#vote_of' do
    let(:votable) { create described_class.to_s.underscore.to_sym }
    let(:user) { create :user }
    let(:another_user) { create :user }
    let!(:user_vote) { create :vote, votable: votable, user: user }

    it 'should return vote of specific user' do
      expect(votable.vote_of(user)).to eq user_vote
    end

    it 'should return nil if user has not any votes for votable' do
      expect(votable.vote_of(another_user)).to be_nil
    end
  end
end
