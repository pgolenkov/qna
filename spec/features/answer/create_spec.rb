require 'rails_helper'

feature 'User can create answer for question', %q{
  In order to help community to resolve question
  As a user
  I'd like to be able to create an answer for question
} do

  given!(:questions) { 3.times.map { create :question } }
  given(:question) { questions.first }

  background do
    visit question_path(question)
  end

  scenario 'User add an answer for the selected question' do
    fill_in 'Body', with: 'Text of answer'
    click_on 'Add answer'

    expect(page).to have_content 'Your answer successfully created!'
    expect(page).to have_content 'Text of answer'
    expect(page).to have_content question.body
  end

  scenario 'User add an answer for the selected question with errors' do
    click_on 'Add answer'

    expect(page).to have_content "Body can't be blank"
  end
end
