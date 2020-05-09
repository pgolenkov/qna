require 'rails_helper'

RSpec.describe SearchesController, type: :controller do
  describe 'GET #show' do
    let(:query) { 'something' }
    let(:questions) { create_list :question, 2 }
    let(:answers) { create_list :answer, 2 }
    let(:comments) { create_list :comment, 2 }

    before do
      allow(ThinkingSphinx).to receive(:search).with(query, classes: [Answer]).and_return(answers)
      allow(ThinkingSphinx).to receive(:search).with(query, classes: [Question]).and_return(questions)
      allow(ThinkingSphinx).to receive(:search).with(query, classes: [Comment]).and_return(comments)
    end

    it 'should render show view' do
      get :show
      expect(response).to render_template :show
    end

    context 'questions only search' do
      context 'when query present and resources params includes question' do

        it 'calls search method of ThinkingSphinx with query and classes Question' do
          expect(ThinkingSphinx).to receive(:search).with(query, classes: [Question])
          get :show, params: { query: query, resources: ['question'] }
        end

        it 'initializes records instance var with results' do
          allow(ThinkingSphinx).to receive(:search).with(query, classes: [Question]).and_return(questions)
          get :show, params: { query: query, resources: ['question'] }
          expect(assigns(:records)).to eq questions
        end
      end

      context 'when query param is not present' do
        it 'does not call search method of ThinkingSphinx' do
          expect(ThinkingSphinx).not_to receive(:search)
          get :show, params: { query: ' ', resources: ['question'] }
        end

        it 'initializes records instance var with empty array' do
          get :show, params: { query: ' ', resources: ['question'] }
          expect(assigns(:records)).to be_empty
        end
      end

      context 'when resources param does not include question' do
        it 'does not call search method of ThinkingSphinx with classes Question' do
          expect(ThinkingSphinx).not_to receive(:search).with(query, classes: [Question])
          expect(ThinkingSphinx).not_to receive(:search).with(query, classes: [Question, Answer])
          get :show, params: { query: 'something', resources: ['answer'] }
        end

        it 'not initializes records instance var with questions' do
          get :show, params: { query: 'something', resources: ['answer'] }
          expect(assigns(:records).map(&:class)).not_to be_any(Question)
        end
      end
    end

    context 'answers only search' do
      context 'when query present and resources params includes answer' do

        it 'calls search method of ThinkingSphinx with query and classes Answer' do
          expect(ThinkingSphinx).to receive(:search).with(query, classes: [Answer])
          get :show, params: { query: query, resources: ['answer'] }
        end

        it 'initializes records instance var with results' do
          get :show, params: { query: query, resources: ['answer'] }
          expect(assigns(:records)).to eq answers
        end
      end

      context 'when query param is not present' do
        it 'does not call search method of ThinkingSphinx' do
          expect(ThinkingSphinx).not_to receive(:search)
          get :show, params: { query: ' ', resources: ['answer'] }
        end

        it 'initializes records instance var with empty array' do
          get :show, params: { query: ' ', resources: ['answer'] }
          expect(assigns(:records)).to be_empty
        end
      end

      context 'when resources param does not include answer' do
        it 'does not call search method of ThinkingSphinx with classes Answer' do
          expect(ThinkingSphinx).not_to receive(:search).with(query, classes: [Answer])
          expect(ThinkingSphinx).not_to receive(:search).with(query, classes: [Question, Answer])
          get :show, params: { query: 'something', resources: ['question'] }
        end

        it 'not initializes records instance var with answers' do
          get :show, params: { query: 'something', resources: ['question'] }
          expect(assigns(:records).map(&:class)).not_to be_any(Answer)
        end
      end
    end

    context 'comments only search' do
      context 'when query present and resources params includes comment' do

        it 'calls search method of ThinkingSphinx with query and classes Comment' do
          expect(ThinkingSphinx).to receive(:search).with(query, classes: [Comment])
          get :show, params: { query: query, resources: ['comment'] }
        end

        it 'initializes records instance var with results' do
          get :show, params: { query: query, resources: ['comment'] }
          expect(assigns(:records)).to eq comments
        end
      end

      context 'when query param is not present' do
        it 'does not call search method of ThinkingSphinx' do
          expect(ThinkingSphinx).not_to receive(:search)
          get :show, params: { query: ' ', resources: ['comment'] }
        end

        it 'initializes records instance var with empty array' do
          get :show, params: { query: ' ', resources: ['comment'] }
          expect(assigns(:records)).to be_empty
        end
      end

      context 'when resources param does not include comment' do
        it 'does not call search method of ThinkingSphinx with classes Comment' do
          expect(ThinkingSphinx).not_to receive(:search).with(query, classes: [Comment])
          expect(ThinkingSphinx).not_to receive(:search).with(query, classes: [Question, Comment])
          get :show, params: { query: 'something', resources: ['question'] }
        end

        it 'not initializes records instance var with comments' do
          get :show, params: { query: 'something', resources: ['question'] }
          expect(assigns(:records).map(&:class)).not_to be_any(Comment)
        end
      end
    end

    context 'when resources param does not present' do
      it 'does not call search method of ThinkingSphinx' do
        expect(ThinkingSphinx).not_to receive(:search)
        get :show, params: { query: 'something' }
      end

      it 'not initializes records instance var' do
        get :show, params: { query: 'something' }
        expect(assigns(:records)).to be_nil
      end
    end
  end
end
