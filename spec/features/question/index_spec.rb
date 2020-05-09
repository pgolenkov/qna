require 'rails_helper'

feature 'User can view questions list', %q{
  In order to find a question of interest
  As a user
  I'd like to be able to view questions list
} do

  given!(:questions) { create_list :question, 2 }

  scenario 'User view titles of questions on index page' do
    visit questions_path

    questions.each { |question| expect(page).to have_content question.title }
  end

  scenario 'User view bodies of questions on index page' do
    visit questions_path

    questions.each { |question| expect(page).to have_content question.body }
  end
end
