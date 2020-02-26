require 'rails_helper'

feature 'User can create answer for question', %q{
  In order to help community to resolve question
  As a user
  I'd like to be able to create an answer for question
} do

  given(:question) { create :question }
  given(:user) { create :user }

  describe 'Authenticated user', js: true do
    background do
      login(user)
      visit question_path(question)
    end

    scenario 'adds an answer for the selected question' do
      fill_in 'Body', with: 'Text of answer'
      click_on 'Add answer'

      expect(page).to have_content 'Text of answer'
      expect(page).to have_content question.body
      expect(find('.new-answer #answer_body').value).to be_empty
    end

    scenario 'adds an answer for the question with attached files' do
      expect(page).to have_no_content 'rails_helper.rb'
      expect(page).to have_no_content 'spec_helper.rb'

      fill_in 'Body', with: 'Text of answer'
      attach_file 'Files', ["#{Rails.root}/spec/rails_helper.rb", "#{Rails.root}/spec/spec_helper.rb"]
      click_on 'Add answer'

      expect(page).to have_content 'rails_helper.rb'
      expect(page).to have_content 'spec_helper.rb'
    end

    scenario 'adds an answer for the selected question with errors' do
      click_on 'Add answer'

      expect(page).to have_content "Body can't be blank"
    end
  end

  describe 'Multiple sessions', js: true do
    scenario "Answer appears on another user's page" do
      Capybara.using_session('user') do
        login(user)
        visit question_path(question)
      end

      Capybara.using_session('guest') do
        visit question_path(question)
      end

      Capybara.using_session('user') do
        fill_in 'Body', with: 'Text of answer'
        click_on 'Add answer'
      end

      Capybara.using_session('guest') do
        expect(page).to have_content 'Text of answer'
      end
    end
  end

  scenario 'Unauthenticated user tries add an answer' do
    visit question_path(question)

    expect(page).to have_no_button 'Add answer'
  end

end
