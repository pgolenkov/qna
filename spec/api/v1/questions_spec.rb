require 'rails_helper'

describe 'Questions API', type: :request do
  let(:headers) { { 'ACCEPT' => 'application/json' } }

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

  describe 'GET /api/v1/questions/:id' do
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

      it 'returns owner of question as an user' do
        subject
        expect(question_json['user']['id']).to eq question.user.id
        expect(question_json['user']['email']).to eq question.user.email
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
        let(:links_json) { question_json['links'] }

        before { subject }

        it 'returns list of links of question' do
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

      context 'question has any attached files' do
        let(:filenames) { ['spec_helper.rb', 'rails_helper.rb']}
        let(:files_json) { question_json['files'] }

        before do
          question.update(files: filenames.map { |filename| fixture_file_upload("spec/#{filename}") })
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

  describe 'POST /api/v1/questions' do
    let(:api_path) { "/api/v1/questions" }
    let(:access_token) { create :access_token }
    let(:params) { { question: attributes_for(:question) } }

    it_behaves_like 'API authorizable' do
      let(:method) { :post }
    end

    context 'authorized' do
      let(:last_question) { Question.order(:created_at).last }
      let(:user) { User.find(access_token.resource_owner_id) }
      let(:question_json) { json['question'] }

      subject { post api_path, params: params.merge(access_token: access_token.token), headers: headers }

      context 'with valid params' do
        it 'should create new question' do
          expect { subject }.to change { Question.count }.by(1)
        end

        it 'should set questions user attribute to resource owner' do
          subject
          expect(last_question.user).to eq user
        end

        it 'returns attributes of question' do
          subject
          %w[id title body created_at updated_at].each do |attr|
            expect(question_json[attr]).to eq last_question.send(attr).as_json
          end
        end

        it 'returns owner of question as an user' do
          subject
          expect(question_json['user']['id']).to eq user.id
          expect(question_json['user']['email']).to eq user.email
        end

        it 'should broadcast new question to channel' do
          expect { subject }.to have_broadcasted_to("questions").with(last_question)
        end
      end

      context 'with links' do
        let(:params) { { question: attributes_for(:question).merge(links_attributes) } }
        let(:links_json) { question_json['links'] }

        context 'where links is valid' do
          let(:links_attributes) do
             { links_attributes: { 0 => { name: 'Google', url: 'https://google.com' }, 1 => { name: 'Yandex', url: 'https://yandex.ru' } } }
          end

          before { subject }

          it 'should add links to question' do
            expect(last_question.links.pluck(:name).sort).to eq ['Google', 'Yandex']
            expect(last_question.links.pluck(:url).sort).to eq ['https://google.com', 'https://yandex.ru']
          end

          it 'returns list of links of question' do
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

          it 'should not create new question' do
            expect { subject }.not_to change { Question.count }
          end

          it 'should not broadcast to channel' do
            expect { subject }.not_to have_broadcasted_to("questions")
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
        let(:params) { { question: attributes_for(:question, :invalid) } }

        it 'should not create new question' do
          expect { subject }.not_to change { Question.count }
        end

        it 'should not broadcast to channel' do
          expect { subject }.not_to have_broadcasted_to("questions")
        end

        it 'returns unprocessable entity status' do
          subject
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'returns errors in json' do
          subject
          expect(json['errors']).to be_present
          expect(json['errors'].first).to eq "Title can't be blank"
        end
      end
    end
  end

  describe 'PATCH /api/v1/questions/:id' do
    let(:api_path) { "/api/v1/questions/#{question.id}" }
    let(:access_token) { create :access_token }
    let(:user) { User.find(access_token.resource_owner_id) }
    let(:question) { create :question, user: user }

    let(:params) { { question: { title: 'Edited title', body: 'Edited body'} } }

    it_behaves_like 'API authorizable' do
      let(:method) { :patch }
    end

    context 'authorized' do
      subject { patch api_path, params: params.merge(access_token: access_token.token), headers: headers }

      let(:question_json) { json['question'] }

      context 'resource owner is an owner of question' do
        before { subject }

        context 'with valid params' do
          it 'should change question' do
            expect(question.reload.title).to eq 'Edited title'
            expect(question.body).to eq 'Edited body'
          end

          it 'returns edited attributes of question' do
            question.reload
            %w[id title body created_at updated_at].each do |attr|
              expect(question_json[attr]).to eq question.send(attr).as_json
            end
          end
        end

        context 'with invalid params' do
          let(:params) { { question: { title: ' ', body: 'Edited body'} } }

          it 'should not change question' do
            expect { subject }.to_not change(question, :title)
            expect { subject }.to_not change(question, :body)
          end

          it 'returns unprocessable entity status' do
            subject
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it 'returns errors in json' do
            subject
            expect(json['errors']).to be_present
            expect(json['errors'].first).to eq "Title can't be blank"
          end
        end
      end

      context 'resource owner is not an owner of question' do
        let(:question) { create :question }

        it 'should not change question' do
          expect { subject }.to_not change(question, :title)
          expect { subject }.to_not change(question, :body)
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

  describe 'DELETE /api/v1/questions/:id' do
    let(:api_path) { "/api/v1/questions/#{question.id}" }
    let(:access_token) { create :access_token }
    let(:user) { User.find(access_token.resource_owner_id) }
    let!(:question) { create :question, user: user }

    it_behaves_like 'API authorizable' do
      let(:method) { :delete }
    end

    context 'authorized' do
      subject { delete api_path, params: { access_token: access_token.token }, headers: headers }

      describe 'when resource owner is an author of question' do
        it 'should destroy question' do
          expect { subject }.to change { Question.count }.by(-1)
          expect(Question).not_to exist(question.id)
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

      describe 'when resource owner is not an author of question' do
        let!(:question) { create :question }

        it 'should not destroy question' do
          expect { subject }.not_to change { Question.count }
          expect(Question).to exist(question.id)
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
