Rails.application.routes.draw do

  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root "tweets#index"
  resources :users, except: %i[ edit ] do
    member do
      get "following", "followers"
    end
  end

  resources :tweets
  resources :follows, only: %i[create destroy]
  resources :notifications, only: %i[index]

  get "/settings/profile", to: "users#edit", as: "settings"
  get "/:username", to: "users#show", as: "username"
end
