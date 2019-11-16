require 'rails_helper'

feature 'User can sign in',%q{
  In order to ask questions
  As an unauthenticated user
  I'd like to be able to sign in
} do

  given(:user) { create :user }

  scenario 'Registered user try to sign in' do
    login(user)

    expect(page).to have_content 'Signed in successfully.'
  end

  scenario 'Unregistered user try to sign in' do
    visit new_user_session_path
    fill_in 'Email', with: 'unregistered_user@test.com'
    fill_in 'Password', with: 'Aa123456'

    click_on 'Log in'

    expect(page).to have_content 'Invalid Email or password.'
  end

end
