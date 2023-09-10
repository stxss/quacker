class SetupTweets < ActiveRecord::Migration[7.0]
  def change
    create_table :tweets do |t|
      t.string :type

      t.string :body
      t.references :user, foreign_key: true, unique: true, null: false

      t.references :parent
      t.references :retweet_original
      t.references :quoted_tweet, default: nil

      t.integer :retweets_count, null: false, default: 0
      t.integer :likes_count, null: false, default: 0
      t.integer :comments_count, null: false, default: 0
      t.integer :quote_tweets_count, null: false, default: 0

      t.references :root, default: nil
      t.integer :height, default: 0
      t.integer :depth, default: 0

      t.float :relevance, scale: 3, default: 1.0

      t.datetime :deleted_at, default: nil
      t.timestamps
    end

    add_foreign_key :tweets, :tweets, column: :parent_id
    add_foreign_key :tweets, :tweets, column: :retweet_original_id
    add_foreign_key :tweets, :tweets, column: :quoted_tweet_id
    add_foreign_key :tweets, :tweets, column: :root_id
  end
end
