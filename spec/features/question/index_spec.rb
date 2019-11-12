require 'rails_helper'

feature 'User can view questions list', %q{
  In order to find a question of interest
  As a user
  I'd like to be able to view questions list
} do

  given!(:questions) { 3.times.map { create :question } }

  scenario 'User view titles of questions on index page' do
    visit questions_path

    questions.each { |question| expect(page).to have_content question.title }
  end
end
