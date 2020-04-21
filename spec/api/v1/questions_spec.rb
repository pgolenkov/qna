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

  describe 'GET /api/v1/question/:id' do
    let(:question) { create :question }
    let(:api_path) { "/api/v1/questions/#{question.id}" }
    let(:access_token) { create :access_token }

    it_behaves_like 'API authorizable' do
      let(:method) { :get }
    end

    context 'authorized' do
      subject { get api_path, params: { access_token: access_token.token }, headers: headers }
      let(:question_json) { json['question'] }

      it 'returns attributes of question' do
        subject
        %w[id title body created_at updated_at].each do |attr|
          expect(question_json[attr]).to eq question.send(attr).as_json
        end
      end

      context 'question has any comments' do
        let!(:comments) { create_list :comment, 2, commentable: question }
        let(:comment) { comments.first }
        let(:comments_json) { question_json['comments'] }
        let(:comment_json) { comments_json.first }

        before { subject }

        it 'returns list of comments of question' do
          expect(comments_json.size).to eq comments.size
        end

        it 'returns attributes of each comment' do
          %w[id body created_at updated_at].each do |attr|
            expect(comment_json[attr]).to eq comment.send(attr).as_json
          end
        end

        it 'returns owner of comment as an user' do
          expect(comment_json['user']['id']).to eq comment.user.id
          expect(comment_json['user']['email']).to eq comment.user.email
        end
      end

      context 'question has any links' do
        let!(:links) { create_list :link, 2, linkable: question }
        let(:link) { links.sort_by(&:id).first }
        let(:links_json) { question_json['links'] }
        let(:link_json) { links_json.sort_by { |l| l['id'] }.first }

        before { subject }

        it 'returns list of links of question' do
          expect(links_json.size).to eq links.size
        end

        it 'returns attributes of each link' do
          %w[id name url created_at updated_at].each do |attr|
            expect(link_json[attr]).to eq link.send(attr).as_json
          end
        end
      end

      it 'returns list of urls of attached files of question'
    end
  end
end
