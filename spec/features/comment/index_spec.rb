require 'rails_helper'

feature 'User can view comments for question or answer', %q{
  In order to find out other users opinions
  As a guest or user
  I'd like to be able to view comments for question or answer
} do

  given(:question) { create :question }
  given(:answer) { create :answer, question: question }
  given(:question_comments) { create_list :comment, 2, commentable: question }
  given(:answer_comments) { create_list :comment, 2, commentable: answer }

  scenario 'User views comments for question' do
    question_comments
    visit question_path(question)

    within "#question-#{question.id}-comments" do
      expect(page).to have_content question_comments.first.body
      expect(page).to have_content question_comments.second.body
    end
  end

  scenario 'User views comments for answer' do
    answer_comments
    visit question_path(question)

    within "#answer-#{answer.id}-comments" do
      expect(page).to have_content answer_comments.first.body
      expect(page).to have_content answer_comments.second.body
    end
  end
end
