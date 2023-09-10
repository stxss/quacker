class SetupLikes < ActiveRecord::Migration[7.0]
  def change
    create_table :likes do |t|
      t.references :tweet, foreign_key: true, unique: true, null: false
      t.references :user, foreign_key: true, unique: true, null: false

      t.integer :likes_count, null: false, default: 0

      t.timestamps
    end
  end
end
