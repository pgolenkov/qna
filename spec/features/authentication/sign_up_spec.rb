require 'rails_helper'

feature 'User can sign up',%q{
  In order to sign in
  As an unauthenticated user
  I'd like to be able to sign up
} do

  given(:user) { create :user }
  background { visit new_user_registration_path }

  scenario 'Unauthenticated unregistered user try to sign up' do
    fill_in 'Email', with: 'new_user@test.com'
    fill_in 'Password', with: 'Aa123456'
    fill_in 'Password confirmation', with: 'Aa123456'

    click_on 'Sign up'
    expect(page).to have_content 'Welcome! You have signed up successfully.'
    expect(page).to have_content 'new_user@test.com'
  end

  scenario 'Unauthenticated registered user try to sign up' do
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    fill_in 'Password confirmation', with: user.password

    click_on 'Sign up'
    expect(page).to have_content 'Email has already been taken'
    expect(page).not_to have_content user.email
  end

  scenario 'User try to sign up with errors' do
    fill_in 'Email', with: 'new_user@test.com'
    fill_in 'Password', with: 'Aa123456'

    click_on 'Sign up'
    expect(page).to have_content "Password confirmation doesn't match Password"
  end

  scenario 'Authenticated user try to sign up' do
    login(user)
    visit new_user_registration_path

    expect(page).to have_content 'You are already signed in.'
  end

end
