require 'rails_helper'

feature 'User can view question page', %q{
  In order to view question details
  As a user
  I'd like to be able to open page for question
} do

  given!(:questions) { 3.times.map { create :question } }
  given(:question) { questions.first }

  scenario 'User opens question page from index page' do
    visit questions_path
    click_on question.title

    expect(page).to have_content question.title
    expect(page).to have_content question.body
  end

  scenario 'User sees answers for question on question page' do
    answers = 3.times.map { create :answer, question: question }
    visit question_path(question)

    answers.each { |answer| expect(page).to have_content answer.body }
  end
end
