require 'rails_helper'

feature 'User can create answer for question', %q{
  In order to help community to resolve question
  As a user
  I'd like to be able to create an answer for question
} do

  given(:question) { create :question }

  describe 'Authenticated user' do
    given(:user) { create :user }

    background do
      login(user)
      visit question_path(question)
    end

    scenario 'adds an answer for the selected question' do
      fill_in 'Body', with: 'Text of answer'
      click_on 'Add answer'

      expect(page).to have_content 'Your answer successfully created!'
      expect(page).to have_content 'Text of answer'
      expect(page).to have_content question.body
    end

    scenario 'adds an answer for the selected question with errors' do
      click_on 'Add answer'

      expect(page).to have_content "Body can't be blank"
    end
  end

  scenario 'Unauthenticated user tries add an answer' do
    visit question_path(question)
    click_on 'Add answer'

    expect(page).to have_content 'You need to sign in or sign up before continuing.'
  end

end
