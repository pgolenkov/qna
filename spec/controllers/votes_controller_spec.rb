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
end
