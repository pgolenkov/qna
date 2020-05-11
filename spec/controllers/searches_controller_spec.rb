require 'rails_helper'

RSpec.describe SearchesController, type: :controller do
  describe 'GET #show' do
    let(:service) { double 'Services::Search' }
    let(:query) { 'something' }
    let(:resources) { ['resource1', 'resource2'] }
    let(:results) { double 'Results of search' }

    before do
      allow(Services::Search).to receive(:new).and_return(service)
      allow(service).to receive(:call).and_return(results)
    end

    context 'when no query param' do
      it 'should render show view' do
        get :show
        expect(response).to render_template :show
      end

      it 'does not initializes and call Search service' do
        expect(Services::Search).not_to receive(:new)
        expect(service).not_to receive(:call)
        get :show
      end
    end

    context 'when no resources param' do
      it 'should render show view' do
        get :show, params: { query: query }
        expect(response).to render_template :show
      end

      it 'does not initializes and call Search service' do
        expect(Services::Search).not_to receive(:new)
        expect(service).not_to receive(:call)
        get :show, params: { query: query }
      end
    end

    context 'when params present' do
      it 'should render show view' do
        get :show, params: { query: query, resources: resources }
        expect(response).to render_template :show
      end

      it 'sends query and resources params to Search service and calls it' do
        expect(Services::Search).to receive(:new).with(query, resources).and_return(service)
        expect(service).to receive(:call)
        get :show, params: { query: query, resources: resources }
      end

      it 'initializes records instance var with results' do
        get :show, params: { query: query, resources: resources }
        expect(assigns(:records)).to eq results
      end
    end
  end
end
