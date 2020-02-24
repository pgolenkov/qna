require 'rails_helper'

feature 'User can create question', %q{
  In order to get answer from community
  As a user
  I'd like to be able to create a question
} do

  given(:user) { create :user }

  describe 'Authenticated user' do
    background do
      login(user)
      visit questions_path
      click_on 'Ask question'
    end

    scenario 'asks a question' do
      fill_in 'Title', with: 'Title of question'
      fill_in 'Body', with: 'Text of question'
      click_on 'Ask'

      expect(page).to have_content 'Your question successfully created!'
      expect(page).to have_content 'Title of question'
      expect(page).to have_content 'Text of question'
    end

    scenario 'asks a question with attached files' do
      expect(page).to have_no_content 'rails_helper.rb'
      expect(page).to have_no_content 'spec_helper.rb'

      fill_in 'Title', with: 'Title of question'
      fill_in 'Body', with: 'Text of question'
      attach_file 'Files', ["#{Rails.root}/spec/rails_helper.rb", "#{Rails.root}/spec/spec_helper.rb"]
      click_on 'Ask'

      expect(page).to have_content 'rails_helper.rb'
      expect(page).to have_content 'spec_helper.rb'
    end

    scenario 'asks a question with errors' do
      click_on 'Ask'

      expect(page).to have_content "Title can't be blank"
    end
  end

  describe 'Multiple sessions', js: true do
    scenario "Question appears on another user's page" do
      Capybara.using_session('user') do
        login(user)
        visit questions_path
        click_on 'Ask question'
      end

      Capybara.using_session('guest') do
        visit questions_path
      end

      Capybara.using_session('user') do
        fill_in 'Title', with: 'Title of question'
        fill_in 'Body', with: 'Text of question'
        click_on 'Ask'
      end

      Capybara.using_session('guest') do
        expect(page).to have_content 'Title of question'
      end
    end
  end

  scenario 'Unauthenticated User tries to ask a question' do
    visit questions_path
    click_on 'Ask question'

    expect(page).to have_content 'You need to sign in or sign up before continuing.'
  end
end
