class UpdateTweetParentIdToNull < ActiveRecord::Migration[7.0]
  def change
    change_column_default :tweets, :parent_tweet_id, from: nil, to: -1
  end
end
