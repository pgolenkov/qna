require 'rails_helper'

describe 'Answers API', type: :request do
  let(:headers) { { 'CONTENT-TYPE' => 'application/json',
                    'ACCEPT' => 'application/json' } }

  describe 'GET /api/v1/questions/:id/answers' do
    let(:question) { create :question }
    let(:api_path) { "/api/v1/questions/#{question.id}/answers" }
    let(:access_token) { create :access_token }
    let!(:answers) { create_list :answer, 2, question: question }

    it_behaves_like 'API authorizable' do
      let(:method) { :get }
    end

    context 'authorized' do
      let(:answers_json) { json['answers'] }

      before do
        get api_path, params: { access_token: access_token.token }, headers: headers
      end

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
    let(:answer) { create :answer }
    let(:api_path) { "/api/v1/answers/#{answer.id}" }
    let(:access_token) { create :access_token }

    it_behaves_like 'API authorizable' do
      let(:method) { :get }
    end

    context 'authorized' do
      subject { get api_path, params: { access_token: access_token.token }, headers: headers }
      let(:answer_json) { json['answer'] }

      it 'returns attributes of answer' do
        subject
        %w[body rating best? created_at updated_at].each do |attr|
          expect(answer_json[attr]).to eq answer.send(attr).as_json
        end
      end

      it 'returns owner of answer as an user' do
        subject
        expect(answer_json['user']['id']).to eq answer.user.id
        expect(answer_json['user']['email']).to eq answer.user.email
      end

      context 'answer has any comments' do
        let!(:comments) { create_list :comment, 2, commentable: answer }
        let(:comment) { comments.first }
        let(:comments_json) { answer_json['comments'] }
        let(:comment_json) { comments_json.first }

        before { subject }

        it 'returns list of comments of answer' do
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

      context 'answer has any links' do
        let!(:links) { create_list :link, 2, linkable: answer }
        let(:links_json) { answer_json['links'] }

        before { subject }

        it 'returns list of links of answer' do
          expect(links_json.size).to eq links.size
        end

        it 'returns attributes of each link' do
          links.each do |link|
            link_json = links_json.find { |l| l['id'] == link.id }
            %w[id name url gist? gist_raw created_at updated_at].each do |attr|
              expect(link_json[attr]).to eq link.send(attr).as_json
            end
          end
        end
      end

      context 'answer has any attached files' do
        let(:filenames) { ['spec_helper.rb', 'rails_helper.rb']}
        let(:files_json) { answer_json['files'] }

        before do
          answer.update(files: filenames.map { |filename| fixture_file_upload("spec/#{filename}") })
          subject
        end

        it 'returns list of of attached files of question' do
          expect(files_json.size).to eq filenames.size
        end

        it 'returns attributes of each file' do
          filenames.each do |filename|
            file_json = files_json.find { |f| f['filename'] == filename }
            expect(file_json['url']).to include filename
          end
        end
      end
    end
  end
end
