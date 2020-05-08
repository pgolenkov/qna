require 'sphinx_helper'

feature 'User can search the question', %q{
  In order to find needed question
  As a user
  I'd like to be able to search for the question
}, sphinx: true do

  given!(:first_question) { create :question, title: 'First title', body: 'One body' }
  given!(:second_question) { create :question, title: 'Second title', body: 'Two body' }

  before { visit search_path }

  scenario 'User searches the question by title' do
    ThinkingSphinx::Test.run do
      expect(page).not_to have_content 'Results'
      expect(page).not_to have_content first_question.title
      expect(page).not_to have_content second_question.title

      fill_in 'Query', with: 'first'
      click_on 'Search'

      expect(page).to have_content 'Results'
      expect(page).to have_content first_question.title
      expect(page).not_to have_content second_question.title

      fill_in 'Query', with: 'second'
      click_on 'Search'

      expect(page).to have_content 'Results'
      expect(page).not_to have_content first_question.title
      expect(page).to have_content second_question.title

      fill_in 'Query', with: 'title'
      click_on 'Search'

      expect(page).to have_content 'Results'
      expect(page).to have_content first_question.title
      expect(page).to have_content second_question.title

      fill_in 'Query', with: 'something'
      click_on 'Search'

      expect(page).not_to have_content 'Results'
      expect(page).not_to have_content first_question.title
      expect(page).not_to have_content second_question.title
      expect(page).to have_content 'No questions found'
    end
  end

  scenario 'User searches the question by body' do
    ThinkingSphinx::Test.run do
      expect(page).not_to have_content 'Results'
      expect(page).not_to have_content first_question.title
      expect(page).not_to have_content second_question.title

      fill_in 'Query', with: 'one'
      click_on 'Search'

      expect(page).to have_content 'Results'
      expect(page).to have_content first_question.title
      expect(page).not_to have_content second_question.title

      fill_in 'Query', with: 'two'
      click_on 'Search'

      expect(page).to have_content 'Results'
      expect(page).not_to have_content first_question.title
      expect(page).to have_content second_question.title

      fill_in 'Query', with: 'body'
      click_on 'Search'

      expect(page).to have_content 'Results'
      expect(page).to have_content first_question.title
      expect(page).to have_content second_question.title
    end
  end
end
