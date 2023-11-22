class SetupUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :username, :string, null: false
    add_column :users, :display_name, :string
    add_column :users, :biography, :string
    add_column :users, :location, :string
    add_column :users, :website, :string
    add_column :users, :birth_date, :date

    add_column :users, :likes_count, :integer, null: false, default: 0
    add_column :users, :follows_count, :integer, null: false, default: 0
    add_column :users, :tweets_count, :integer, null: false, default: 0
    add_column :users, :notifications_count, :integer, null: false, default: 0
    add_column :users, :bookmarks_count, :integer, null: false, default: 0

    add_index :users, :username, unique: true
    add_index :users, :display_name, unique: true
  end
end
