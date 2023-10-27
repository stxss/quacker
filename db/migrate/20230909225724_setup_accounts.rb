class SetupAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :accounts do |t|
      t.references :user, unique: true, null: false
      t.integer :allow_media_tagging, default: 0
      t.boolean :private_visibility, null: false, default: false
      t.boolean :private_likes, null: false, default: false
      t.boolean :sensitive_media, null: false, default: false
      t.boolean :display_sensitive_media, null: false, default: false
      t.boolean :remove_blocked_and_muted_accounts, null: false, default: true
      t.boolean :muted_notif_you_dont_follow, null: false, default: false
      t.boolean :muted_notif_dont_follow_you, null: false, default: false
      t.boolean :muted_notif_new_account, null: false, default: false
      t.boolean :muted_notif_default_profile_pic, null: false, default: false
      t.boolean :muted_notif_no_confirm_email, null: false, default: false
      t.boolean :allow_message_request_from_everyone, null: false, default: false
      t.boolean :show_read_receipts, null: false, default: false
      t.boolean :hide_potentially_sensitive_content, null: false, default: false

      t.timestamps
    end

    add_foreign_key :accounts, :users, on_delete: :cascade
  end
end
