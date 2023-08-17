class RenameRetweetIdColumn < ActiveRecord::Migration[7.0]
  def change
    rename_column :tweets, :retweet_id, :retweet_original_id
  end
end
