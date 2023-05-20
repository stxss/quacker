class CreateNotifications < ActiveRecord::Migration[7.0]
  def change
    create_table :notifications do |t|
      t.integer :type
      t.integer :notifier_id, foreign_key: true
      t.integer :notified_id, foreign_key: true
      t.integer :tweet_id, foreign_key: true
      t.timestamps
    end
  end
end
