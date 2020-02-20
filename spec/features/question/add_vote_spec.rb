require 'rails_helper'

feature 'Authenticated user can add vote to the question', %q{
  In order to show the author that his question is good or bad
  As an authenticated user
  I'd like to be able to vote one of the questions
} do

  given(:user) { create :user }
  given(:question) { create :question }
  given(:user_question) { create :question, user: user }

  describe 'Authenticated user', js: true do
    background { login(user) }

    describe 'votes for another user question' do
      background do
        visit question_path(question)
      end

      scenario 'as like' do
        within ".question" do
          expect(page).to have_link 'Like'
          expect(page).to have_link 'Dislike'
          click_on 'Like'
          expect(page).to have_no_link 'Like'
          expect(page).to have_no_link 'Dislike'
          expect(page).to have_content 'You like it!'
        end
      end

      scenario 'as dislike' do
        within ".question" do
          expect(page).to have_link 'Like'
          expect(page).to have_link 'Dislike'
          click_on 'Dislike'
          expect(page).to have_no_link 'Like'
          expect(page).to have_no_link 'Dislike'
          expect(page).to have_content 'You dislike it!'
        end
      end
    end

    describe 'when tries to vote for his question' do
      background { visit question_path(user_question) }

      scenario 'doesnt view any like or dislike links' do
        expect(page).to have_no_link 'Like'
        expect(page).to have_no_link 'Dislike'
      end
    end
  end

  describe 'Unauthenticated user', js: true do
    background { visit question_path(question) }

    scenario 'doesnt view any like or dislike links' do
      expect(page).to have_no_link 'Like'
      expect(page).to have_no_link 'Dislike'
    end
  end
end
