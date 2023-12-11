require "sidekiq/web"

Rails.application.routes.draw do
  devise_for :users

  authenticate :user do
    mount Sidekiq::Web => "/sidekiq"
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  get "/home", to: "posts#index"
  root to: redirect("/home", status: 302)

  get "search", to: "search#index", as: "search"

  get "/messages/search/", to: "messages#search", as: "messages_search"
  get "/:username/status/:id/share", to: "messages#share_post", as: "share_post"

  resources :messages, only: [:new, :create, :destroy]
  resources :conversations, only: [:new, :show, :index, :create, :destroy]

  # path "" -> removes the /users/ prefix from url, specifying username as the identifier instead of the default :id
  # has to be placed after the other resources with names that can be mistaken for usernames, as rails reads the routes from top to bottom, so by placing the /messages, /bookmarks and such routes first, they will take precedence over the "users" route.
  resources :users, path: "", param: :username, only: [:index, :new, :create, :update, :destroy] do
    member do
      get :following, :followers
    end
  end

  get "/bookmarks", to: "posts/bookmarks#index", as: "user_bookmarks"

  resources :posts, only: [:new, :create, :destroy] do
    resource :like, module: :posts, only: [:update]
    resource :bookmark, module: :posts, only: [:update]
    resource :reposts, module: :posts, only: [:update]
  end

  # Create a quote or comment on a post
  get "/:username/status/:id/quote", to: "quotes#new", as: "new_quote"
  get "/:username/status/:id/comment", to: "comments#new", as: "new_comment"

  scope "/posts" do
    resources :quotes, only: [:create, :destroy]
    resources :comments, only: [:create, :destroy]
  end

  resources :follows, only: %i[create destroy update]
  resources :notifications, only: %i[index]
  resources :accounts, path: "settings", only: %i[index edit update]

  # Show a single post
  get "/:username/status/:id", to: "posts#show", as: "single_post"
  get "/:id/view_blocked", to: "posts#view_blocked_single_post", as: "view_blocked_single_post"

  get "/:username", to: "users#show", as: "username"

  get "/:username/replies", to: "users#show_replies", as: "username_replies"

  get "/:username/likes", to: "users#index_liked_posts", as: "user_likes"

  # get "/:username/following", to: "users#following", as: "user_following"
  # get "/:username/followers", to: "users#followers", as: "user_followers"

  resources :muted_accounts, path: "/settings/muted/accounts", only: [:index, :create, :destroy]

  resources :blocks, path: "/settings/blocked/all", only: [:index, :create, :destroy]
  get "/:username/view_blocked_posts", to: "users#view_blocked_posts", as: "view_blocked_posts"
  get "/:username/replies/view_blocked_replies", to: "users#view_blocked_replies", as: "view_blocked_replies"
  get "/:username/likes/view_blocked_likes", to: "users#view_blocked_likes", as: "view_blocked_likes"

  resources :muted_words, path: "settings/muted/words", only: [:index, :new, :create, :destroy]

  # Edit profile display_name, bio, etc
  get "/settings/profile/", to: "users#edit", as: "settings"

  # General display of account settings
  get "/settings/account/", to: "accounts#index", as: "settings_account"

  # Your account section

  # Privacy and safety section
  get "/settings/privacy_and_safety/", to: "accounts#edit_privacy_and_safety", as: "settings_privacy"
  get "/settings/audience_and_tagging/", to: "accounts#edit_audience_and_tagging", as: "settings_audience_and_tagging"
  # get "/settings/tagging/", to: "accounts#edit_tagging", as: "settings_tagging"

  get "/settings/your_posts/", to: "accounts#edit_your_posts", as: "settings_your_posts"

  get "/settings/content_you_see/", to: "accounts#edit_content_you_see", as: "settings_content_you_see"
  get "/settings/search", to: "accounts#edit_search", as: "settings_search"

  get "/settings/mute_and_block/", to: "accounts#edit_mute_and_block", as: "settings_mute_and_block"
  get "/settings/blocked/all", to: "accounts#edit_blocked_all", as: "settings_blocked_all"
  get "/settings/blocked/imported", to: "accounts#edit_blocked_imported", as: "settings_blocked_imported"
  get "/settings/notifications/advanced_filters", to: "accounts#edit_notifications_advanced_filters", as: "settings_notifications_advanced_filters"

  get "/settings/direct_messages/", to: "accounts#edit_direct_messages", as: "settings_direct_messages"

  get "/notifications/follower_requests", to: "notifications#index_follow_request_notification", as: "notifications_follow_request"
  patch "/notifications/follower_requests", to: "follows#update"
  # get "/settings//", to: "accounts#edit_", as: "settings_"

  # get "/settings/account/", to: "", as: "settings"
  # get "/settings/notifications/", to: "", as: "settings_notifications"
  # get "/settings/security_and_account_access", to: "", as: "settings_security"
  # get "/settings/accessibility_display_and_languages", to: "", as: "settings_display"
end
