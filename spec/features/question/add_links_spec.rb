require 'rails_helper'

feature 'User can add links to question', %q{
  In order to give more information about question
  As an author of question
  I'd like to be able to add links to question
} do

  given(:user) { create :user }
  background { login(user) }

  describe 'User creates question', js: true do
    background { visit new_question_path }

    scenario 'with one link' do
      fill_in 'Title', with: 'Title of question'
      fill_in 'Body', with: 'Text of question'

      within '#links' do
        click_on 'Add link'
        fill_in 'Name', with: 'Google'
        fill_in 'Url', with: 'https://google.com'
      end
      click_on 'Ask'

      expect(page).to have_link 'Google', href: 'https://google.com'
    end

    scenario 'with several links' do
      fill_in 'Title', with: 'Title of question'
      fill_in 'Body', with: 'Text of question'

      within '#links' do
        click_on 'Add link'
        fill_in 'Name', with: 'Google'
        fill_in 'Url', with: 'https://google.com'

        click_on 'Add link'
        within all('.nested-fields').last do
          fill_in 'Name', with: 'Yandex'
          fill_in 'Url', with: 'https://yandex.ru'
        end
      end
      click_on 'Ask'

      expect(page).to have_link 'Google', href: 'https://google.com'
      expect(page).to have_link 'Yandex', href: 'https://yandex.ru'
    end
  end

end
