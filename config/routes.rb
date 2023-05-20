Rails.application.routes.draw do

  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root "tweets#index"
  resources :users do
    member do
      get "following", "followers"
    end
  end

  resources :tweets
  resources :follows, only: %i[create destroy]

  get "/:username", to: "users#show", as: "username"
end
