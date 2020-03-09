require 'rails_helper'

feature 'User can sign in with omniuath',%q{
  In order to ask questions
  As an unauthenticated user
  I'd like to be able to sign in with omniauth
} do

  background { visit new_user_session_path }

  describe "Sign in with Github" do
    it "user can sign in with Github account" do
      mock_auth_hash
      click_on "Sign in with GitHub"
      expect(page).to have_content('Successfully authenticated from Github account')
      expect(page).to have_content("mockuser@email.com")
      expect(page).to have_content("Log out")
    end

    it "can handle authentication error" do
      OmniAuth.config.mock_auth[:github] = :invalid_credentials
      click_on "Sign in with GitHub"
      expect(page).to have_content('Could not authenticate you from GitHub')
    end
  end

end
