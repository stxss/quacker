class SetupLikes < ActiveRecord::Migration[7.0]
  def change
    create_table :likes do |t|
      t.references :tweet, unique: true, null: false
      t.references :user, unique: true, null: false

      t.integer :likes_count, null: false, default: 0

      t.timestamps
    end

    add_foreign_key :likes, :tweets, on_delete: :cascade
    add_foreign_key :likes, :users, on_delete: :cascade
  end
end
