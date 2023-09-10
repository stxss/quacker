class SetupNotifications < ActiveRecord::Migration[7.0]
  def change
    create_table :notifications do |t|
      t.integer :notification_type

      t.references :tweet, foreign_key: true
      t.references :notifier
      t.references :notified

      t.timestamps
    end

    add_foreign_key :notifications, :users, column: :notifier_id
    add_foreign_key :notifications, :users, column: :notified_id
  end
end
