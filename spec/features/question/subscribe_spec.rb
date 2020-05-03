require 'rails_helper'

feature 'User can subscribe the question', %q{
  In order to receive notifications about question
  As an authenticated user
  I'd like to be able to subscribe the question
} do

  given(:question) { create :question }

  describe 'Authenticated user' do
    given(:user) { create :user }

    background { login(user) }

    describe 'as not an author of question' do
      scenario 'subscribes the question', js: true do
        visit question_path(question)
        expect(page).not_to have_content 'You are subscribed to this question'
        click_on 'Subscribe'

        expect(page).not_to have_link('Subscribe')
        expect(page).to have_content 'You are subscribed to this question'
      end

      context 'when user has got a subscription of the question' do
        background { question.subscriptions.create!(user: user) }

        scenario 'views the message that he is already subscribed' do
          visit question_path(question)

          expect(page).not_to have_link('Subscribe')
          expect(page).to have_content 'You are subscribed to this question'
        end
      end
    end

    describe 'as an author of question' do
      given(:question) { create :question, user: user }

      scenario 'views message that he is already subscribed as author' do
        visit question_path(question)

        expect(page).not_to have_link('Subscribe')
        expect(page).to have_content 'You are subscribed to this question'
      end
    end
  end

  describe 'Unauthenticated user' do
    scenario 'can not subscribe the question' do
      visit question_path(question)

      expect(page).not_to have_link('Subscribe')
      expect(page).not_to have_content 'You are subscribed to this question'
    end
  end

end
