require 'rails_helper'

RSpec.describe VotesController, type: :controller do
  let(:question) { create :question }
  let(:user) { create :user }

  describe 'POST #create' do
    subject { post :create, params: { votable_type: 'Question', votable_id: question.id, status: :like }, format: :json }

    describe 'by authenticated user' do
      before { login(user) }

      context 'first vote' do
        it 'should create new vote for question' do
          expect { subject }.to change { question.votes.count }.by(1)
        end
        it 'should return vote in json with created status' do
          subject
          expect(response).to have_http_status(:created)
          vote = JSON.parse(response.body)['vote']
          expect(vote['status']).to eq 'like'
        end
      end

      context 'second vote' do
        before { question.votes.create!(user: user) }

        it 'should not new vote for question and return error status' do
          expect { subject }.not_to change { Vote.count }
        end
        it 'should return errors in json with unprocessable entity status' do
          subject
          expect(response).to have_http_status(:unprocessable_entity)
          errors = JSON.parse(response.body)['errors']
          expect(errors).to eq ["User has already been taken"]
        end
      end

      context 'with invalid params' do
        subject { post :create, params: { votable_type: 'Question', votable_id: question.id, vote: { status: 0 } }, format: :json }

        it 'should not create new vote' do
          expect { subject }.not_to change { Vote.count }
        end

        it 'should return errors in json with unprocessable entity status' do
          subject
          expect(response).to have_http_status(:unprocessable_entity)
          errors = JSON.parse(response.body)['errors']
          expect(errors).to eq ["Status can't be blank"]
        end
      end
    end

    describe 'by unauthenticated user' do
      it 'should not create new vote' do
        expect { subject }.not_to change { Vote.count }
      end
      it 'should return unauthorized status' do
        subject
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:vote) { create :vote, user: user, votable: question }
    let!(:another_user_vote) { create :vote, votable: question }

    subject { delete :destroy, params: { id: vote }, format: :json }

    describe 'by authenticated user' do
      before { login(user) }

      context 'his own vote' do
        it 'should destroy vote' do
          expect { subject }.to change { question.votes.count }.by(-1)
        end
        it 'should return vote with votable information and ok status' do
          subject
          expect(response).to have_http_status(:ok)
          vote_json = JSON.parse(response.body)['vote']
          expect(vote_json['votable_type']).to eq vote.votable_type
          expect(vote_json['votable_id']).to eq vote.votable_id
        end
      end

      context 'another user`s vote' do

        subject { delete :destroy, params: { id: another_user_vote }, format: :json }

        it 'should not destroy vote' do
          expect { subject }.not_to change { Vote.count }
        end
        it 'should return forbidden status' do
          subject
          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    describe 'by unauthenticated user' do
      it 'should not destroy vote' do
        expect { subject }.not_to change { Vote.count }
      end
      it 'should return unauthorized status' do
        subject
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
