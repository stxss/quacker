class SetupNotifications < ActiveRecord::Migration[7.0]
  def change
    create_table :notifications do |t|
      t.integer :notification_type

      t.references :post, optional: true
      t.references :notifier
      t.references :notified

      t.timestamps
    end

    add_foreign_key :notifications, :users, column: :notifier_id
    add_foreign_key :notifications, :users, column: :notified_id
    add_foreign_key :notifications, :posts, on_delete: :cascade
  end
end
