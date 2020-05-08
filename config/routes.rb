require 'sidekiq/web'

Rails.application.routes.draw do
  authenticate :user, ->(user) { user.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  use_doorkeeper
  devise_for :users, controllers: { omniauth_callbacks: 'oauth_callbacks' }

  resources :questions do
    resources :answers, shallow: true do
      patch :make_best, on: :member
    end
    resource :subscription, only: [:create, :destroy]
  end

  resources :attachments, only: :destroy
  resources :links, only: :destroy
  resources :votes, only: [:create, :destroy]
  resources :comments, only: :create
  resources :awards, only: :index

  resource :user, only: [:edit, :update]

  resource :search, only: [:show]

  namespace :api do
    namespace :v1 do
      resources :profiles, only: [:index] do
        get :me, on: :collection
      end

      resources :questions, only: [:index, :show, :create, :update, :destroy] do
        resources :answers, only: [:index, :show, :create, :update, :destroy], shallow: true
      end
    end
  end

  root to: "questions#index"

  mount ActionCable.server => '/cable'
end
