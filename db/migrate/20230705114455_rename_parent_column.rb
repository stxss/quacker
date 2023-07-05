class RenameParentColumn < ActiveRecord::Migration[7.0]
  def change
    rename_column :tweets, :tweet_id_to_reply, :parent_tweet_id
  end
end
