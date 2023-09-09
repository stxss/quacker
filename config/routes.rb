Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  get "/home", to: "tweets#index"
  root to: redirect("/home", status: 302)

  # Health check endpoint
  get "/up/", to: "up#index", as: :up
  get "/up/databases", to: "up#databases", as: :up_databases

  # For sideqik stuff, look into
  # https://github.com/nickjj/docker-rails-example/blob/9b74c7b9cb86ec2d5a1246cecea9f0e6a779e15a/config/routes.rb#L4

  # path "" -> removes the /users/ prefix from url, specifying username as the identifier instead of the default :id
  resources :users, path: "", param: :username, only: [:index, :new, :create, :update, :destroy] do
    member do
      get :following, :followers
    end
  end

  resources :tweets, except: [:show, :new]

  scope "/tweets" do
    resources :quotes, only: [:create, :destroy]
    resources :comments, only: [:create, :destroy]
  end

  # Actions to create and destroy a retweet
  post "/tweets/retweet/:retweet_original_id", to: "retweets#create", as: "retweet"
  delete "/tweets/retweet/:id", to: "retweets#destroy", as: "unretweet"

  match "/compose/tweet", to: "tweets#new", via: [:get, :post], as: "compose_tweet"

  resources :follows, only: %i[create destroy update]
  resources :notifications, only: %i[index]
  resources :accounts, path: "settings", only: %i[index edit update]

  get "/turbo/tweet_button/(:valid)", to: "tweets#tweet_btn", as: :turbo_tweet_button
  get "/compose/turbo/tweet_button(:valid)", to: "tweets#tweet_btn", as: :turbo_tweet_button_compose
  get "/compose/null", to: "tweets#tweet_btn", as: :turbo_tweet_button_compose_quote_comment

  # Show a single tweet
  get "/:username/status/:id", to: "tweets#show", as: "single_tweet"

  get "/:username", to: "users#show", as: "username"

  get "/:username/with_replies", to: "users#show_replies", as: "username_replies"

  get "/:username/likes", to: "users#index_liked_tweets", as: "user_likes"
  resources :likes, path: "/:username/likes", only: [:create, :destroy]

  get "/i/bookmarks", to: "bookmarks#index", as: "user_bookmarks"
  resources :bookmarks, path: "/i/bookmarks", only: [:create, :destroy]

  # Edit profile display_name, bio, etc
  get "/settings/profile/", to: "users#edit", as: "settings"

  # General display of account settings
  get "/settings/account/", to: "accounts#index", as: "settings_account"

  # Your account section

  # Privacy and safety section
  get "/settings/privacy_and_safety/", to: "accounts#edit_privacy_and_safety", as: "settings_privacy"
  get "/settings/audience_and_tagging/", to: "accounts#edit_audience_and_tagging", as: "settings_audience_and_tagging"
  get "/settings/tagging/", to: "accounts#edit_tagging", as: "settings_tagging"

  get "/settings/your_tweets/", to: "accounts#edit_your_tweets", as: "settings_your_tweets"

  get "/settings/content_you_see/", to: "accounts#edit_content_you_see", as: "settings_content_you_see"
  get "/settings/search", to: "accounts#edit_search", as: "settings_search"

  get "/settings/mute_and_block/", to: "accounts#edit_mute_and_block", as: "settings_mute_and_block"
  get "/settings/blocked/all", to: "accounts#edit_blocked_all", as: "settings_blocked_all"
  get "/settings/blocked/imported", to: "accounts#edit_blocked_imported", as: "settings_blocked_imported"
  get "/settings/muted/all", to: "accounts#edit_muted_all", as: "settings_muted_all"
  get "/settings/muted_keywords", to: "accounts#edit_muted_keywords", as: "settings_muted_keywords"
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
