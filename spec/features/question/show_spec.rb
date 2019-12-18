require 'rails_helper'

feature 'User can view question page', %q{
  In order to view question details
  As a user
  I'd like to be able to open page for question
} do

  given!(:questions) { create_list :question, 2 }
  given(:question) { questions.first }
  given!(:answers) do
    create_list(:answer, 2, question: question).tap { |answers| answers.last.best! }
  end

  scenario 'User opens question page from index page' do
    visit questions_path
    click_on question.title

    expect(page).to have_content question.title
    expect(page).to have_content question.body
  end

  scenario 'User sees answers for question on question page' do
    visit question_path(question)

    answers.each { |answer| expect(page).to have_content answer.body }
  end

  scenario 'User sees the best answer first with mark The best answer' do
    visit question_path(question)
    
    expect(answers.last.body).to appear_before(answers.first.body)
    within "#answer-#{answers.last.id}" do
      expect(page).to have_content('The best answer')
      expect(page).to have_no_link('Mark as the best')
    end
  end
end
