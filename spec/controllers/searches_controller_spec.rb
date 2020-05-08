require 'rails_helper'

RSpec.describe SearchesController, type: :controller do
  describe 'GET #show' do
    before { allow(Question).to receive(:search) }

    it 'should render show view' do
      get :show
      expect(response).to render_template :show
    end

    context 'when query param present' do
      let(:query) { 'something' }
      let(:questions) { create_list :question, 2 }

      it 'calls search method of Question with query' do
        expect(Question).to receive(:search).with(query)
        get :show, params: { query: query }
      end

      it 'initializes questions instance var with results' do
        allow(Question).to receive(:search).with(query).and_return(questions)
        get :show, params: { query: query }
        expect(assigns(:questions)).to eq questions
      end
    end

    context 'when query param is not present' do
      it 'does not call search method of Question' do
        expect(Question).not_to receive(:search)
        get :show
      end

      it 'initializes questions instance var with empty array' do
        get :show, params: { query: ' ' }
        expect(assigns(:questions)).to be_empty
      end
    end
  end
end
