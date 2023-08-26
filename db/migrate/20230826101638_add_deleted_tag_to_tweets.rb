class AddDeletedTagToTweets < ActiveRecord::Migration[7.0]
  def change
    add_column :tweets, :deleted_at, :datetime, default: nil
  end
end
