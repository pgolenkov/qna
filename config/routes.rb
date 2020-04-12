Rails.application.routes.draw do
  use_doorkeeper
  devise_for :users, controllers: { omniauth_callbacks: 'oauth_callbacks' }

  resources :questions do
    resources :answers, shallow: true do
      patch :make_best, on: :member
    end
  end

  resources :attachments, only: :destroy
  resources :links, only: :destroy
  resources :votes, only: [:create, :destroy]
  resources :comments, only: :create
  resources :awards, only: :index
  resource :user, only: [:edit, :update]

  root to: "questions#index"

  mount ActionCable.server => '/cable'
end
