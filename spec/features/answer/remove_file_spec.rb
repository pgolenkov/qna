require 'rails_helper'

feature 'User can remove file from answer', %q{
  In order to correct files of answer
  As an author of answer
  I'd like to be able to remove file of an answer
} do

  given(:user) { create :user }
  given(:question) { create :question }
  given!(:answer) { create :answer, question: question, user: user, files: [fixture_file_upload('spec/rails_helper.rb'), fixture_file_upload('spec/spec_helper.rb')] }
  given!(:another_answer) { create :answer, question: question, files: [fixture_file_upload('spec/rails_helper.rb')] }

  describe 'Authenticated user', js: true do
    background do
      login(user)
      visit question_path(question)
    end

    scenario 'removes specific attached file' do
      within "#answer-#{answer.id}" do
        expect(page).to have_content 'rails_helper.rb'
        expect(page).to have_content 'spec_helper.rb'
      end

      within "#file-#{answer.files.first.id}" do
        click_on 'Delete'
      end

      within "#answer-#{answer.id}" do
        expect(page).not_to have_content 'rails_helper.rb'
        expect(page).to have_content 'spec_helper.rb'
      end
    end

    scenario "tries to delete files of another user's answer" do
      within "#file-#{another_answer.files.first.id}" do
        expect(page).to have_no_link "Delete"
      end
    end
  end

  scenario 'Unauthenticated user cannot remove images from answers' do
    visit question_path(question)
    within "#file-#{answer.files.first.id}" do
      expect(page).to have_no_link "Delete"
    end
  end
end
