require 'rails_helper'

describe 'Answers API', type: :request do
  let(:headers) { { 'ACCEPT' => 'application/json' } }

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

  describe 'POST /api/v1/questions/:id/answers' do
    let(:question) { create :question }
    let(:api_path) { "/api/v1/questions/#{question.id}/answers" }
    let(:access_token) { create :access_token }
    let(:params) { { answer: attributes_for(:answer) } }

    it_behaves_like 'API authorizable' do
      let(:method) { :post }
    end

    context 'authorized' do
      let(:last_answer) { Answer.order(:created_at).last }
      let(:user) { User.find(access_token.resource_owner_id) }
      let(:answer_json) { json['answer'] }

      subject { post api_path, params: params.merge(access_token: access_token.token), headers: headers }

      context 'with valid params' do
        it 'should create new answer' do
          expect { subject }.to change { Answer.count }.by(1)
        end

        it 'should create answer for question' do
          subject
          expect(last_answer.question).to eq question
        end

        it 'should set answer user attribute to resource owner' do
          subject
          expect(last_answer.user).to eq user
        end

        it 'returns attributes of answer' do
          subject
          %w[body rating best? created_at updated_at].each do |attr|
            expect(answer_json[attr]).to eq last_answer.send(attr).as_json
          end
        end

        it 'returns owner of answer as an user' do
          subject
          expect(answer_json['user']['id']).to eq user.id
          expect(answer_json['user']['email']).to eq user.email
        end

        it 'should broadcast new answer to channel' do
          expect { subject }.to have_broadcasted_to("answers-#{question.id}").with(last_answer)
        end
      end

      context 'with links' do
        let(:params) { { answer: attributes_for(:answer).merge(links_attributes) } }
        let(:links_json) { answer_json['links'] }

        context 'where links is valid' do
          let(:links_attributes) do
             { links_attributes: { 0 => { name: 'Google', url: 'https://google.com' }, 1 => { name: 'Yandex', url: 'https://yandex.ru' } } }
          end

          before { subject }

          it 'should add links to answer' do
            expect(last_answer.links.pluck(:name).sort).to eq ['Google', 'Yandex']
            expect(last_answer.links.pluck(:url).sort).to eq ['https://google.com', 'https://yandex.ru']
          end

          it 'returns list of links of answer' do
            expect(links_json.size).to eq 2
          end

          it 'returns attributes of each link' do
            expect(links_json.map { |l| l['name'] }.sort).to eq ['Google', 'Yandex']
            expect(links_json.map { |l| l['url'] }.sort).to eq ['https://google.com', 'https://yandex.ru']
          end
        end

        context 'where links is not valid' do
          let(:links_attributes) do
            { links_attributes: { 0 => { url: 'https://google.com' } } }
          end

          it 'should not create new answer' do
            expect { subject }.not_to change { Answer.count }
          end

          it 'should not broadcast to channel' do
            expect { subject }.not_to have_broadcasted_to("answers-#{question.id}")
          end

          it 'returns unprocessable entity status' do
            subject
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it 'returns errors in json' do
            subject
            expect(json['errors']).to be_present
            expect(json['errors'].first).to eq "Links name can't be blank"
          end
        end
      end

      context 'with invalid params' do
        let(:params) { { answer: attributes_for(:answer, :invalid) } }

        it 'should not create new answer' do
          expect { subject }.not_to change { Answer.count }
        end

        it 'should not broadcast to channel' do
          expect { subject }.not_to have_broadcasted_to("answers-#{question.id}")
        end

        it 'returns unprocessable entity status' do
          subject
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'returns errors in json' do
          subject
          expect(json['errors']).to be_present
          expect(json['errors'].first).to eq "Body can't be blank"
        end
      end
    end
  end

  describe 'PATCH /api/v1/answers/:id' do
    let(:api_path) { "/api/v1/answers/#{answer.id}" }
    let(:access_token) { create :access_token }
    let(:user) { User.find(access_token.resource_owner_id) }
    let(:answer) { create :answer, user: user }

    let(:params) { { answer: { body: 'Edited body'} } }

    it_behaves_like 'API authorizable' do
      let(:method) { :patch }
    end

    context 'authorized' do
      subject { patch api_path, params: params.merge(access_token: access_token.token), headers: headers }

      let(:answer_json) { json['answer'] }

      context 'resource owner is an owner of answer' do
        before { subject }

        context 'with valid params' do
          it 'should change answer' do
            expect(answer.reload.body).to eq 'Edited body'
          end

          it 'returns edited attributes of answer' do
            answer.reload
            %w[id body rating best? created_at updated_at].each do |attr|
              expect(answer_json[attr]).to eq answer.send(attr).as_json
            end
          end
        end

        context 'with invalid params' do
          let(:params) { { answer: { body: ' '} } }

          it 'should not change answer' do
            expect { subject }.to_not change(answer, :body)
          end

          it 'returns unprocessable entity status' do
            subject
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it 'returns errors in json' do
            subject
            expect(json['errors']).to be_present
            expect(json['errors'].first).to eq "Body can't be blank"
          end
        end
      end

      context 'resource owner is not an owner of answer' do
        let(:answer) { create :answer }

        it 'should not change answer' do
          expect { subject }.to_not change(answer, :body)
        end

        it 'should return forbidden status' do
          subject
          expect(response).to have_http_status(:forbidden)
        end

        it 'returns empty response' do
          subject
          expect(response.body).to be_empty
        end
      end
    end
  end

  describe 'DELETE /api/v1/answers/:id' do
    let(:api_path) { "/api/v1/answers/#{answer.id}" }
    let(:access_token) { create :access_token }
    let(:user) { User.find(access_token.resource_owner_id) }
    let!(:answer) { create :answer, user: user }

    it_behaves_like 'API authorizable' do
      let(:method) { :delete }
    end

    context 'authorized' do
      subject { delete api_path, params: { access_token: access_token.token }, headers: headers }

      describe 'when resource owner is an author of answer' do
        it 'should destroy answer' do
          expect { subject }.to change { Answer.count }.by(-1)
          expect(Answer).not_to exist(answer.id)
        end

        it 'should return no content status' do
          subject
          expect(response).to have_http_status(:no_content)
        end

        it 'returns empty response' do
          subject
          expect(response.body).to be_empty
        end
      end

      describe 'when resource owner is not an author of answer' do
        let!(:answer) { create :answer }

        it 'should not destroy answer' do
          expect { subject }.not_to change { Answer.count }
          expect(Answer).to exist(answer.id)
        end

        it 'should return forbidden status' do
          subject
          expect(response).to have_http_status(:forbidden)
        end

        it 'returns empty response' do
          subject
          expect(response.body).to be_empty
        end
      end
    end
  end
end
