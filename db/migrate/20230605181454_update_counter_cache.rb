class UpdateCounterCache < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :likes_count, :integer
    add_column :users, :follows_count, :integer
    add_column :users, :tweets_count, :integer
    add_column :tweets, :likes_count, :integer
  end
end
