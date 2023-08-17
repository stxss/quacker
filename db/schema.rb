# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_08_17_142448) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.integer "user_id"
    t.integer "allow_media_tagging", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "sensitive_media", default: false, null: false
    t.boolean "display_sensitive_media", default: false, null: false
    t.boolean "remove_blocked_and_muted_accounts", default: true, null: false
    t.boolean "muted_notif_you_dont_follow", default: false, null: false
    t.boolean "muted_notif_dont_follow_you", default: false, null: false
    t.boolean "muted_notif_new_account", default: false, null: false
    t.boolean "muted_notif_default_profile_pic", default: false, null: false
    t.boolean "muted_notif_no_confirm_email", default: false, null: false
    t.boolean "allow_message_request_from_everyone", default: false, null: false
    t.boolean "show_read_receipts", default: false, null: false
    t.boolean "private_visibility", default: false
    t.boolean "hide_potentially_sensitive_content", default: false, null: false
    t.index ["user_id"], name: "index_accounts_on_user_id", unique: true
  end

  create_table "bookmarks", force: :cascade do |t|
    t.integer "tweet_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tweet_id", "user_id"], name: "index_bookmarks_on_tweet_id_and_user_id", unique: true
  end

  create_table "follows", force: :cascade do |t|
    t.integer "follower_id"
    t.integer "followed_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_request", default: false, null: false
    t.index ["followed_id"], name: "index_follows_on_followed_id"
    t.index ["follower_id", "followed_id"], name: "index_follows_on_follower_id_and_followed_id", unique: true
    t.index ["follower_id"], name: "index_follows_on_follower_id"
  end

  create_table "likes", force: :cascade do |t|
    t.integer "tweet_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "likes_count", default: 0
    t.index ["tweet_id", "user_id"], name: "index_likes_on_tweet_id_and_user_id", unique: true
  end

  create_table "notifications", force: :cascade do |t|
    t.integer "notification_type"
    t.integer "notifier_id"
    t.integer "notified_id"
    t.integer "tweet_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tweets", force: :cascade do |t|
    t.string "body"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "parent_tweet_id"
    t.integer "likes_count"
    t.integer "retweet_original_id"
    t.integer "retweet_body"
    t.integer "quoted_retweet_id"
    t.integer "retweets_count"
    t.integer "quote_tweets_count"
    t.integer "comments_count"
    t.string "type"
    t.integer "root_id"
    t.integer "height", default: 0
    t.integer "depth", default: 0
    t.index ["parent_tweet_id"], name: "index_tweets_on_parent_tweet_id"
    t.index ["user_id", "retweet_original_id"], name: "index_tweets_on_user_id_and_retweet_original_id", unique: true
    t.index ["user_id"], name: "index_tweets_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username"
    t.string "display_name"
    t.string "biography"
    t.string "location"
    t.string "website"
    t.date "birth_date"
    t.integer "likes_count"
    t.integer "follows_count"
    t.integer "tweets_count"
    t.integer "notifications_count"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "tweets", "tweets", column: "parent_tweet_id"
end
