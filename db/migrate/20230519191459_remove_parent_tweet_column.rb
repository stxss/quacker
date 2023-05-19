class RemoveParentTweetColumn < ActiveRecord::Migration[7.0]
  def change
    remove_column :tweets, :parent_tweet_id
  end
end
