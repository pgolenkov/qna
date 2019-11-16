require 'rails_helper'

feature 'User can log out',%q{
  In order to change user
  As an authenticated user
  I'd like to be able to log out
} do

  given(:user) { create :user }

  scenario 'Athenticated user try to log out' do
    login(user)
    click_on 'Log out'
    expect(page).to have_content 'Signed out successfully.'
  end

  scenario 'Unathenticated user try to log out' do
    visit root_path
    expect(page).not_to have_content 'Log out'
  end
end
