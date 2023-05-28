class UpdateNullValues < ActiveRecord::Migration[7.0]
  def change
    change_column :accounts, :sensitive_tweets, :boolean, null: false
    change_column :accounts, :display_sensitive_tweets, :boolean, null: false
    change_column :accounts, :remove_blocked_and_muted_accounts, :boolean, null: false
    change_column :accounts, :muted_notif_you_dont_follow, :boolean, null: false
    change_column :accounts, :muted_notif_dont_follow_you, :boolean, null: false
    change_column :accounts, :muted_notif_new_account, :boolean, null: false
    change_column :accounts, :muted_notif_default_profile_pic, :boolean, null: false
    change_column :accounts, :muted_notif_no_confirm_email, :boolean, null: false
    change_column :accounts, :allow_message_request_from_everyone, :boolean, null: false
    change_column :accounts, :show_read_receipts, :boolean, null: false
    rename_column :accounts, :photo_tagging, :allow_media_tagging
  end
end
