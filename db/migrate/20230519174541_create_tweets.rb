class CreateTweets < ActiveRecord::Migration[7.0]
  def change
    create_table :tweets do |t|
      t.string :body
      t.integer :user_id, foreign_key: true
      t.integer :parent_tweet_id, foreign_key: true


      t.timestamps
    end

    add_index :tweets, :user_id
  end
end
