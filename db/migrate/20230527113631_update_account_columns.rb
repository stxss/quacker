class UpdateAccountColumns < ActiveRecord::Migration[7.0]
  def change
    add_column :accounts, :sensitive_tweets, :boolean, default: false
    add_column :accounts, :display_sensitive_tweets, :boolean, default: false
    add_column :accounts, :remove_blocked_and_muted_accounts, :boolean, default: true
    add_column :accounts, :muted_notif_you_dont_follow, :boolean, default: false
    add_column :accounts, :muted_notif_dont_follow_you, :boolean, default: false
    add_column :accounts, :muted_notif_new_account, :boolean, default: false
    add_column :accounts, :muted_notif_default_profile_pic, :boolean, default: false
    add_column :accounts, :muted_notif_no_confirm_email, :boolean, default: false
    add_column :accounts, :allow_message_request_from_everyone, :boolean, default: false
    add_column :accounts, :show_read_receipts, :boolean, default: false
  end
end
