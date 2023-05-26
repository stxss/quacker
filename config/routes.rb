Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "registrations" }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root "tweets#index"

  # path "" -> removes the /users/ prefix from url, specifying username as the identifier instead of the default :id
  resources :users, path: "", param: :username, only: [:index, :new, :create, :edit, :update, :destroy] do
    member do
      get :following, :followers
    end
  end

  resources :tweets
  resources :follows, only: %i[create destroy]
  resources :notifications, only: %i[index]

  get "/settings/profile/", to: "users#edit", as: "settings"
  get "/:username", to: "users#show", as: "username"
end
