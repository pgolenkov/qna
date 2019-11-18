require 'rails_helper'

feature 'User can destroy his question', %q{
  In order to remove unnecessary question
  As a authenticated user
  I'd like to be able to destroy my question
} do

  given(:user) { create :user }
  given(:question) { create :question, user: user }
  given(:another_question) { create :question }

  scenario 'Authenticated user destroys his question' do
    login(user)
    visit question_path(question)
    expect(page).to have_content(question.title)

    click_on 'Delete question'

    expect(page).to have_content('Your question successfully destroyed.')
    expect(page).not_to have_content(question.title)
  end

  scenario 'Authenticated user tries to destroy another`s question' do
    login(user)
    visit question_path(another_question)

    expect(page).to have_no_link('Delete question')
  end

  scenario 'Unauthenticated user tries to destroy question' do
    visit question_path(question)

    expect(page).to have_no_link('Delete question')
  end
end
