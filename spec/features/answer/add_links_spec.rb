require 'rails_helper'

feature 'User can add links to answer', %q{
  In order to give more information about answer
  As an author of answer
  I'd like to be able to add links to answer
} do

  given(:user) { create :user }
  given(:question) { create :question }
  given(:my_gist_link) { 'https://gist.github.com/pashex/9b698d35948fe219a6d7441450053624' }

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

    scenario 'with gist link and view gist raw' do
      fill_in 'Body', with: 'Text of answer'

      within '#links' do
        click_on 'Add link'
        fill_in 'Name', with: 'My gist'
        fill_in 'Url', with: my_gist_link
      end
      click_on 'Add answer'

      expect(page).to have_no_link 'My gist', href: my_gist_link
      expect(page).to have_content "My test gist"
    end

    scenario 'with wrong gist link and view error message' do
      wrong_gist_link = my_gist_link.gsub('9','8')

      fill_in 'Body', with: 'Text of answer'

      within '#links' do
        click_on 'Add link'
        fill_in 'Name', with: 'My gist'
        fill_in 'Url', with: wrong_gist_link
      end
      click_on 'Add answer'

      expect(page).to have_no_link 'My gist', href: wrong_gist_link
      expect(page).to have_content "Wrong gist link"
    end
  end

  describe 'User edits his answer', js: true do
    given(:answer) { create :answer, user: user }

    context 'when answer has no any links' do

      scenario 'and add link to answer' do
        visit question_path(answer.question)
        within "#answer-#{answer.id}" do
          click_on 'Edit answer'

          expect(page).to have_no_link 'Google', href: 'https://google.com'

          within '#links' do
            click_on 'Add link'
            fill_in 'Name', with: 'Google'
            fill_in 'Url', with: 'https://google.com'
          end
          click_on 'Save'

          expect(page).to have_link 'Google', href: 'https://google.com'
        end
      end
    end

    context 'when answer has links' do
      given!(:link) { create :link, linkable: answer }

      scenario 'and add link to answer' do
        visit question_path(answer.question)
        within "#answer-#{answer.id}" do
          click_on 'Edit answer'

          expect(page).to have_link link.name, href: link.url
          expect(page).to have_no_link 'Google', href: 'https://google.com'

          within '#links' do
            click_on 'Add link'
            fill_in 'Name', with: 'Google'
            fill_in 'Url', with: 'https://google.com'
          end
          click_on 'Save'

          expect(page).to have_link link.name, href: link.url
          expect(page).to have_link 'Google', href: 'https://google.com'
        end
      end
    end
  end

end
