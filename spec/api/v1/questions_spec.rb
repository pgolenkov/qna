require 'rails_helper'

describe 'Questions API', type: :request do
  let(:headers) { { 'CONTENT-TYPE' => 'application/json',
                    'ACCEPT' => 'application/json' } }

  describe 'GET /api/v1/questions' do
    let(:api_path) { '/api/v1/questions' }
    let(:access_token) { create :access_token }
    let!(:questions) { create_list :question, 2 }

    it_behaves_like 'API authorizable' do
      let(:method) { :get }
    end

    context 'authorized' do
      let(:question) { questions.first }
      let(:questions_json) { json['questions'] }
      let(:question_json) { questions_json.first }

      before do
        get api_path, params: { access_token: access_token.token }, headers: headers
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
