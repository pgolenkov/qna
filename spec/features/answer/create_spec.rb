require 'rails_helper'

feature 'User can create answer for question', %q{
  In order to help community to resolve question
  As a user
  I'd like to be able to create an answer for question
} do

  given(:question) { create :question }

  describe 'Authenticated user', js: true do
    given(:user) { create :user }

    background do
      login(user)
      visit question_path(question)
    end

    scenario 'adds an answer for the selected question' do
      fill_in 'Body', with: 'Text of answer'
      click_on 'Add answer'

      expect(page).to have_content 'Text of answer'
      expect(page).to have_content question.body
      expect(find('.new-answer #answer_body').value).to be_empty
    end

    scenario 'adds an answer for the selected question with errors' do
      click_on 'Add answer'

      expect(page).to have_content "Body can't be blank"
    end
  end

  scenario 'Unauthenticated user tries add an answer' do
    visit question_path(question)

    expect(page).to have_no_button 'Add answer'
  end

end
