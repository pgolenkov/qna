require 'rails_helper'

feature 'User can add links to answer', %q{
  In order to give more information about answer
  As an author of answer
  I'd like to be able to add links to answer
} do

  given(:user) { create :user }
  given(:question) { create :question }

  background { login(user) }

  describe 'User creates answer', js: true do
    background { visit question_path(question) }

    scenario 'with one link' do
      fill_in 'Body', with: 'Text of answer'

      within '.new-answer' do
        within '#links' do
          click_on 'Add link'
          fill_in 'Name', with: 'Google'
          fill_in 'Url', with: 'https://google.com'
        end
        click_on 'Add answer'
      end

      within '.answers' do
        expect(page).to have_link 'Google', href: 'https://google.com'
      end
    end

    scenario 'with several links' do
      fill_in 'Body', with: 'Text of answer'

      within '.new-answer' do
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
        click_on 'Add answer'
      end

      within '.answers' do
        expect(page).to have_link 'Google', href: 'https://google.com'
        expect(page).to have_link 'Yandex', href: 'https://yandex.ru'
      end
    end

    scenario 'with invalid url link' do
      fill_in 'Body', with: 'Text of answer'

      within '.new-answer' do
        within '#links' do
          click_on 'Add link'
          fill_in 'Name', with: 'Google'
          fill_in 'Url', with: 'htps://google.com'
        end
        click_on 'Add answer'
      end

      expect(page).to have_no_link 'Google', href: 'https://google.com'
      expect(page).to have_content "Links url is not a valid URL"
    end
  end

end
