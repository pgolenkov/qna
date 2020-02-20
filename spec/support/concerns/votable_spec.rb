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
      let!(:like_votes) { create_list :vote, 4, :like, votable: votable }
      let!(:dislike_votes) { create_list :vote, 1, :dislike, votable: votable }

      it 'should return zero' do
        expect(votable.rating).to eq 3
      end
    end
  end
end
