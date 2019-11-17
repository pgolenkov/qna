require 'rails_helper'

feature 'User can create question', %q{
  In order to get answer from community
  As a user
  I'd like to be able to create a question
} do

  describe 'Authenticated user' do
    given(:user) { create :user }

    background do
      login(user)
      visit questions_path
      click_on 'Ask question'
    end

    scenario 'asks a question' do
      fill_in 'Title', with: 'Title of question'
      fill_in 'Body', with: 'Text of question'
      click_on 'Ask'

      expect(page).to have_content 'Your question successfully created!'
      expect(page).to have_content 'Title of question'
      expect(page).to have_content 'Text of question'
    end

    scenario 'asks a question with errors' do
      click_on 'Ask'

      expect(page).to have_content "Title can't be blank"
    end
  end

  scenario 'Unauthenticated User tries to ask a question' do
    visit questions_path
    click_on 'Ask question'

    expect(page).to have_content 'You need to sign in or sign up before continuing.'
  end
end
