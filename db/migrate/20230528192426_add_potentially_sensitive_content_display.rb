class AddPotentiallySensitiveContentDisplay < ActiveRecord::Migration[7.0]
  def change
    add_column :accounts, :hide_potentially_sentitive_content, :boolean, null: false, default: false
    rename_column :accounts, :display_sensitive_tweets, :display_sensitive_media
    rename_column :accounts, :sensitive_tweets, :sensitive_media
  end
end
