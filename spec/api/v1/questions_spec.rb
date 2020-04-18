require 'rails_helper'

describe 'Questions API', type: :request do
  let(:headers) { { 'CONTENT-TYPE' => 'application/json',
                    'ACCEPT' => 'application/json' } }

  describe 'GET /api/v1/questions' do
    context 'unauthorized' do
      it 'returns unauthorized status if no access_token' do
        get '/api/v1/questions', headers: headers
        expect(response).to be_unauthorized
      end

      it 'returns unauthorized status if access_token is invalid' do
        get '/api/v1/questions', params: { access_token: '1234' }, headers: headers
        expect(response).to be_unauthorized
      end
    end

    context 'authorized' do
      let(:access_token) { create :access_token }
      let!(:questions) { create_list :question, 2 }
      let(:question) { questions.first }
      let(:questions_json) { json['questions'] }
      let(:question_json) { questions_json.first }

      before do
        get '/api/v1/questions', params: { access_token: access_token.token }, headers: headers
      end

      it 'returns successful status' do
        expect(response).to be_successful
      end

      it 'returns list of questions' do
        expect(questions_json.size).to eq questions.size
      end

      it 'returns attributes of question' do
        %w[id title body created_at updated_at].each do |attr|
          expect(question_json[attr]).to eq question.send(attr).as_json
        end
      end

      it 'returns owner of question as an user' do
        expect(question_json['user']['id']).to eq question.user.id
        expect(question_json['user']['email']).to eq question.user.email
      end
    end
  end
end
