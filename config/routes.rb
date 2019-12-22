Rails.application.routes.draw do
  devise_for :users
  resources :questions do
    resources :answers, shallow: true do
      patch :make_best, on: :member
    end
    patch :remove_file, on: :member
  end

  root to: "questions#index"
end
