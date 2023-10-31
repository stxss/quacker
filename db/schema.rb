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

ActiveRecord::Schema[7.0].define(version: 2023_10_31_130236) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "allow_media_tagging", default: 0
    t.boolean "private_visibility", default: false, null: false
    t.boolean "private_likes", default: false, null: false
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
    t.boolean "hide_potentially_sensitive_content", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "muted_accounts_count", default: 0, null: false
    t.integer "blocks_count", default: 0, null: false
    t.index ["user_id"], name: "index_accounts_on_user_id"
  end

  create_table "blocks", force: :cascade do |t|
    t.bigint "blocker_id", null: false
    t.bigint "blocked_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["blocked_id"], name: "index_blocks_on_blocked_id"
    t.index ["blocker_id", "blocked_id"], name: "index_blocks_on_blocker_id_and_blocked_id", unique: true
    t.index ["blocker_id"], name: "index_blocks_on_blocker_id"
  end

  create_table "bookmarks", force: :cascade do |t|
    t.bigint "tweet_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tweet_id"], name: "index_bookmarks_on_tweet_id"
    t.index ["user_id"], name: "index_bookmarks_on_user_id"
  end

  create_table "conversation_members", id: false, force: :cascade do |t|
    t.bigint "conversation_id", null: false
    t.bigint "member_id", null: false
    t.boolean "left", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id"], name: "index_conversation_members_on_conversation_id"
    t.index ["member_id"], name: "index_conversation_members_on_member_id"
  end

  create_table "conversations", force: :cascade do |t|
    t.bigint "creator_id", null: false
    t.text "name"
    t.integer "messages_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_conversations_on_creator_id"
  end

  create_table "follows", force: :cascade do |t|
    t.bigint "follower_id", null: false
    t.bigint "followed_id", null: false
    t.boolean "is_request", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["followed_id"], name: "index_follows_on_followed_id"
    t.index ["follower_id", "followed_id"], name: "index_follows_on_follower_id_and_followed_id", unique: true
    t.index ["follower_id"], name: "index_follows_on_follower_id"
  end

  create_table "likes", force: :cascade do |t|
    t.bigint "tweet_id", null: false
    t.bigint "user_id", null: false
    t.integer "likes_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tweet_id"], name: "index_likes_on_tweet_id"
    t.index ["user_id"], name: "index_likes_on_user_id"
  end

  create_table "messages", force: :cascade do |t|
    t.text "body"
    t.bigint "sender_id", null: false
    t.bigint "conversation_id", null: false
    t.boolean "read", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
    t.index ["sender_id"], name: "index_messages_on_sender_id"
  end

  create_table "muted_accounts", force: :cascade do |t|
    t.bigint "muter_id", null: false
    t.bigint "muted_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["muted_id"], name: "index_muted_accounts_on_muted_id"
    t.index ["muter_id", "muted_id"], name: "index_muted_accounts_on_muter_id_and_muted_id", unique: true
    t.index ["muter_id"], name: "index_muted_accounts_on_muter_id"
  end

  create_table "muted_words", force: :cascade do |t|
    t.bigint "muter_id", null: false
    t.boolean "from_timeline", default: true, null: false
    t.boolean "from_notifications", default: true, null: false
    t.text "body"
    t.datetime "expiration"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["muter_id", "body"], name: "index_muted_words_on_muter_id_and_body", unique: true
    t.index ["muter_id"], name: "index_muted_words_on_muter_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.integer "notification_type"
    t.bigint "tweet_id"
    t.bigint "notifier_id"
    t.bigint "notified_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["notified_id"], name: "index_notifications_on_notified_id"
    t.index ["notifier_id"], name: "index_notifications_on_notifier_id"
    t.index ["tweet_id"], name: "index_notifications_on_tweet_id"
  end

  create_table "tweets", force: :cascade do |t|
    t.string "type"
    t.text "body"
    t.bigint "user_id", null: false
    t.bigint "parent_id"
    t.bigint "retweet_original_id"
    t.bigint "quoted_tweet_id"
    t.integer "retweets_count", default: 0, null: false
    t.integer "likes_count", default: 0, null: false
    t.integer "comments_count", default: 0, null: false
    t.integer "quote_tweets_count", default: 0, null: false
    t.bigint "root_id"
    t.integer "height", default: 0
    t.integer "depth", default: 0
    t.decimal "relevance", default: "0.0"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_tweets_on_parent_id"
    t.index ["quoted_tweet_id"], name: "index_tweets_on_quoted_tweet_id"
    t.index ["retweet_original_id"], name: "index_tweets_on_retweet_original_id"
    t.index ["root_id"], name: "index_tweets_on_root_id"
    t.index ["user_id"], name: "index_tweets_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username", null: false
    t.string "display_name"
    t.string "biography"
    t.string "location"
    t.string "website"
    t.date "birth_date"
    t.integer "likes_count", default: 0, null: false
    t.integer "follows_count", default: 0, null: false
    t.integer "tweets_count", default: 0, null: false
    t.integer "notifications_count", default: 0, null: false
    t.index ["display_name"], name: "index_users_on_display_name", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "accounts", "users", on_delete: :cascade
  add_foreign_key "bookmarks", "tweets", on_delete: :cascade
  add_foreign_key "bookmarks", "users", on_delete: :cascade
  add_foreign_key "conversation_members", "conversations", on_delete: :cascade
  add_foreign_key "conversation_members", "users", column: "member_id", on_delete: :cascade
  add_foreign_key "conversations", "users", column: "creator_id"
  add_foreign_key "likes", "tweets", on_delete: :cascade
  add_foreign_key "likes", "users", on_delete: :cascade
  add_foreign_key "messages", "conversations", on_delete: :cascade
  add_foreign_key "messages", "users", column: "sender_id"
  add_foreign_key "notifications", "tweets", on_delete: :cascade
  add_foreign_key "notifications", "users", column: "notified_id"
  add_foreign_key "notifications", "users", column: "notifier_id"
  add_foreign_key "tweets", "tweets", column: "parent_id"
  add_foreign_key "tweets", "tweets", column: "quoted_tweet_id", on_delete: :nullify
  add_foreign_key "tweets", "tweets", column: "retweet_original_id", on_delete: :cascade
  add_foreign_key "tweets", "tweets", column: "root_id"
  add_foreign_key "tweets", "users", on_delete: :cascade
end
