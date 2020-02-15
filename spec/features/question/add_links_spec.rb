require 'rails_helper'

feature 'User can add links to question', %q{
  In order to give more information about question
  As an author of question
  I'd like to be able to add links to question
} do

  given(:user) { create :user }
  given(:my_gist_link) { 'https://gist.github.com/pashex/9b698d35948fe219a6d7441450053624' }

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

    scenario 'with invalid url link' do
      fill_in 'Title', with: 'Title of question'
      fill_in 'Body', with: 'Text of question'

      within '#links' do
        click_on 'Add link'
        fill_in 'Name', with: 'Google'
        fill_in 'Url', with: 'htps://google.com'
      end
      click_on 'Ask'

      expect(page).to have_no_link 'Google', href: 'https://google.com'
      expect(page).to have_content "Links url is not a valid URL"
    end

    scenario 'with gist link and view gist raw' do
      fill_in 'Title', with: 'Title of question'
      fill_in 'Body', with: 'Text of question'

      within '#links' do
        click_on 'Add link'
        fill_in 'Name', with: 'My gist'
        fill_in 'Url', with: my_gist_link
      end
      click_on 'Ask'

      expect(page).to have_no_link 'My gist', href: my_gist_link
      expect(page).to have_content "My test gist"
    end

    scenario 'with wrong gist link and view error message' do
      wrong_gist_link = my_gist_link.gsub('9','8')

      fill_in 'Title', with: 'Title of question'
      fill_in 'Body', with: 'Text of question'

      within '#links' do
        click_on 'Add link'
        fill_in 'Name', with: 'My gist'
        fill_in 'Url', with: wrong_gist_link
      end
      click_on 'Ask'

      expect(page).to have_no_link 'My gist', href: wrong_gist_link
      expect(page).to have_content "Wrong gist link"
    end
  end

end
