require 'rails_helper'

RSpec.describe AwardsController, type: :controller do
  let(:user) { create :user }

  describe 'GET #index' do
    subject { get :index }

    describe 'by authenticated user' do
      before { login(user) }

      it 'should render index view' do
        subject
        expect(response).to render_template :index
      end
    end

    describe 'by unauthenticated user' do
      it { should redirect_to(new_user_session_path) }
    end
  end
end
