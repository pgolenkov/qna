require 'rails_helper'

feature 'User can remove file from question', %q{
  In order to correct files of question
  As an author of question
  I'd like to be able to remove file of a question
} do

  given(:user) { create :user }
  given!(:question) { create :question, user: user, files: [fixture_file_upload('spec/rails_helper.rb'), fixture_file_upload('spec/spec_helper.rb')] }
  given(:another_question) { create :question, files: [fixture_file_upload('spec/rails_helper.rb')] }

  describe 'Authenticated user', js: true do
    background { login(user) }

    scenario 'removes specific attached file' do
      visit question_path(question)
      within "#question-file-#{question.files.first.id}" do
        click_on 'Delete'
      end

      expect(page).not_to have_content 'rails_helper.rb'
      expect(page).to have_content 'spec_helper.rb'
    end

    scenario "tries to delete files of another user's question" do
      visit question_path(another_question)
      within "#question-file-#{another_question.files.first.id}" do
        expect(page).to have_no_link "Delete"
      end
    end
  end

  scenario 'Unauthenticated user cannot remove images from questions' do
    visit question_path(question)
    within "#question-file-#{question.files.first.id}" do
      expect(page).to have_no_link "Delete"
    end
  end
end
