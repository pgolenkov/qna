require 'rails_helper'

feature 'User can mark the best answer for question', %q{
  In order to help community to find the best solution of question
  As an author of question
  I'd like to be able to mark one of answers as the best
} do

  given(:user) { create :user }
  given(:question) { create :question, user: user }
  given!(:answers) { create_list :answer, 2, question: question }

  describe 'User as author of question' do
    background do
      login user
      visit question_path(question)
    end

    scenario 'marks one of answers as the best', js: true do
      expect(answers.first.body).to appear_before(answers.last.body)
      within "#answer-#{answers.last.id}" do
        click_on 'Mark as the best'

        expect(page).to have_no_link('Mark as the best')
        expect(page).to have_content('The best answer')
      end
      expect(answers.last.body).to appear_before(answers.first.body)
    end

    describe 'when there is the best answer for the question' do
      background do
        answers.last.best!
        visit question_path(question)
      end

      scenario 'sees the best answer first with mark The best answer' do
        expect(answers.last.body).to appear_before(answers.first.body)
        within "#answer-#{answers.last.id}" do
          expect(page).to have_content('The best answer')
          expect(page).to have_no_link('Mark as the best')
        end
      end

      scenario 'change the best answer to other answer', js: true do
        within "#answer-#{answers.first.id}" do
          click_on 'Mark as the best'
        end

        within "#answer-#{answers.first.id}" do
          expect(page).to have_no_link('Mark as the best')
          expect(page).to have_content('The best answer')
        end

        within "#answer-#{answers.last.id}" do
          expect(page).to have_link('Mark as the best')
          expect(page).to have_no_content('The best answer')
        end

        expect(answers.first.body).to appear_before(answers.last.body)
      end
    end
  end

  describe 'User who is not author of question' do
    given(:other_user) { create :user }

    before do
      login(other_user)
      visit question_path(question)
    end

    scenario "doesn't see links to mark answers as the best" do
      within '.answers' do
        expect(page).to have_no_link('Mark as the best')
      end
    end
  end

  scenario "Guest doesn't see links to mark answers as the best" do
    visit question_path(question)
    within '.answers' do
      expect(page).to have_no_link('Mark as the best')
    end
  end

end
