require 'rails_helper'

describe 'Answers API', type: :request do
  let(:headers) { { 'ACCEPT' => 'application/json' } }
  let(:access_token) { create :access_token }
  let(:user) { User.find(access_token.resource_owner_id) }

  let(:resource_class) { Answer }
  let(:resource) { answer }
  let(:resource_json) { json['answer'] }
  let(:attributes) { %w[id body rating best? created_at updated_at] }

  let(:question) { create :question }

  subject { send method, api_path, params: { access_token: access_token.token }, headers: headers }

  describe 'GET /api/v1/questions/:id/answers' do
    let(:api_path) { "/api/v1/questions/#{question.id}/answers" }
    let(:method) { :get }

    let!(:answers) { create_list :answer, 2, question: question }

    it_behaves_like 'API authorizable'

    context 'authorized' do
      let(:answers_json) { json['answers'] }

      before { subject }

      it 'returns list of answers of question' do
        expect(answers_json.size).to eq answers.size
      end

      it 'returns attributes of each answer and user' do
        answers.each do |answer|
          answer_json = answers_json.find { |a| a['id'] == answer.id }
          %w[body rating best? created_at updated_at].each do |attr|
            expect(answer_json[attr]).to eq answer.send(attr).as_json
          end

          expect(answer_json['user']['id']).to eq answer.user.id
          expect(answer_json['user']['email']).to eq answer.user.email
        end
      end
    end
  end

  describe 'GET /api/v1/answers/:id' do
    let(:api_path) { "/api/v1/answers/#{answer.id}" }
    let(:method) { :get }

    let(:answer) { create :answer }

    it_behaves_like 'API authorizable'
    it_behaves_like 'API serializable'
    it_behaves_like 'API ownerable'
    it_behaves_like 'API commentable'
    it_behaves_like 'API linkable'
    it_behaves_like 'API attachable'
  end

  describe 'POST /api/v1/questions/:id/answers' do
    let(:api_path) { "/api/v1/questions/#{question.id}/answers" }
    let(:method) { :post }

    let(:channel_name) { "answers-#{question.id}" }
    let(:answer) { Answer.order(:created_at).last }
    let(:params) { { answer: attributes_for(:answer) } }

    subject { post api_path, params: params.merge(access_token: access_token.token), headers: headers }

    it_behaves_like 'API authorizable'

    it_behaves_like 'API create resource' do
      let(:invalid_params) { { answer: attributes_for(:answer, :invalid) } }
      let(:invalid_attribute) { 'Body' }
    end

    it_behaves_like 'API create linkable'
    it_behaves_like 'API serializable'
    it_behaves_like 'API ownerable'
  end

  describe 'PATCH /api/v1/answers/:id' do
    let(:api_path) { "/api/v1/answers/#{answer.id}" }
    let(:method) { :patch }

    let(:answer) { create :answer, user: user }

    let(:update_attributes) { { body: 'Edited body' } }
    let(:params) { { answer: update_attributes } }

    subject { patch api_path, params: params.merge(access_token: access_token.token), headers: headers }

    it_behaves_like 'API authorizable'

    it_behaves_like 'API update resource' do
      let(:invalid_params) { { answer: { body: ' '} } }
      let(:invalid_attribute) { 'Body' }
    end
  end

  describe 'DELETE /api/v1/answers/:id' do
    let(:api_path) { "/api/v1/answers/#{answer.id}" }
    let(:method) { :delete }

    let!(:answer) { create :answer, user: user }

    it_behaves_like 'API authorizable'
    it_behaves_like 'API destroy resource'
  end
end
