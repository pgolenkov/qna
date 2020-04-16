require 'rails_helper'

describe 'Profiles API', type: :request do
  let(:headers) { { 'CONTENT-TYPE' => 'application/json',
                    'ACCEPT' => 'application/json' } }

  describe 'GET /api/v1/profiles/me' do
    context 'unauthorized' do
      it 'returns unauthorized status if no access_token' do
        get '/api/v1/profiles/me', headers: headers
        expect(response).to be_unauthorized
      end

      it 'returns unauthorized status if access_token is invalid' do
        get '/api/v1/profiles/me', params: { access_token: '1234' }, headers: headers
        expect(response).to be_unauthorized
      end
    end

    context 'authorized' do
      let(:access_token) { create :access_token }
      it 'returns sucessful status' do
        get '/api/v1/profiles/me', params: { access_token: access_token.token }, headers: headers
        expect(response).to be_successful
      end
    end
  end
end
