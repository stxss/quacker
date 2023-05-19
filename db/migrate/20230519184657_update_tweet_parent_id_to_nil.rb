class UpdateTweetParentIdToNil < ActiveRecord::Migration[7.0]
  def change
    change_column_default :tweets, :parent_tweet_id, nil
  end
end
