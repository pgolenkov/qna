require 'rails_helper'

feature 'User can add award when create question', %q{
  In order to increase motivation of community
  As an authenticated user
  I'd like to be able to create award with a question
} do

  given(:user) { create :user }

  background do
    login(user)
    visit questions_path
    click_on 'Ask question'
    fill_in 'Title', with: 'Title of question'
    fill_in 'Body', with: 'Text of question'
  end

  scenario 'User add award when asks a question' do
    within '.award' do
      fill_in 'Name', with: 'Award name'
      attach_file 'Image', "#{Rails.root}/public/apple-touch-icon.png"
    end

    click_on 'Ask'

    expect(page).to have_content 'Your question successfully created!'
    expect(page).to have_content 'For the best answer you will receive'
    expect(page).to have_content 'Award name'
    expect(page).to have_css("img[src*='apple-touch-icon.png']")
  end

  scenario 'User add award with invalid image when asks a question' do
    within '.award' do
      fill_in 'Name', with: 'Award name'
      attach_file 'Image', "#{Rails.root}/spec/spec_helper.rb"
    end

    click_on 'Ask'

    expect(page).not_to have_content 'Your question successfully created!'
    expect(page).not_to have_content 'For the best answer you will receive'
    expect(page).not_to have_content 'Award name'
    expect(page).to have_content "Award image has an invalid content type"
  end

  scenario 'User add award without image when asks a question' do
    within '.award' do
      fill_in 'Name', with: 'Award without image'
    end

    click_on 'Ask'

    expect(page).not_to have_content 'Your question successfully created!'
    expect(page).not_to have_content 'For the best answer you will receive'
    expect(page).not_to have_content 'Award without image'
    expect(page).to have_content "Award image can't be blank"
  end

  scenario 'User asks a question with empty award name' do
    within '.award' do
      fill_in 'Name', with: ' '
    end

    click_on 'Ask'

    expect(page).to have_content 'Your question successfully created!'
    expect(page).not_to have_content 'For the best answer you will receive'
  end
end
