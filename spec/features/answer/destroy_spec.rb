require 'rails_helper'

feature 'User can destroy his answer', %q{
  In order to remove unnecessary answer
  As a authenticated user
  I'd like to be able to destroy my answer
} do

  given(:question) { create :question }
  given(:user) { create :user }
  given!(:answer) { create :answer, question: question, user: user }
  given!(:another_answer) { create :answer, question: question }

  scenario 'Authenticated user destroys his answer' do
    login(user)
    visit question_path(question)

    expect(page).to have_content(answer.body)

    within("#answer-#{answer.id}") do
      click_on 'Delete answer'
    end

    expect(page).to have_content('Your answer successfully destroyed.')
    expect(page).not_to have_content(answer.body)
  end

  scenario 'Authenticated user don`t see link to destroy another`s answer' do
    login(user)
    visit question_path(question)

    expect(page.find("#answer-#{another_answer.id}")).to have_no_link('Delete answer')
  end

  scenario 'Unauthenticated user don`t see link to destroy answer' do
    visit question_path(question)

    expect(page).to have_no_link('Delete answer')
  end
end
