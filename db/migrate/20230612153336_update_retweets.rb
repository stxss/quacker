class UpdateRetweets < ActiveRecord::Migration[7.0]
  def change
    add_column :tweets, :retweet_id, :integer
    add_column :tweets, :retweet_body, :integer
    rename_column :tweets, :parent_id, :tweet_id_to_reply
    drop_table :retweets
  end
end
