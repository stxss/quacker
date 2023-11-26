class SetupLikes < ActiveRecord::Migration[7.0]
  def change
    create_table :likes do |t|
      t.references :post, unique: true, null: false
      t.references :user, unique: true, null: false

      t.timestamps
    end

    add_foreign_key :likes, :posts, on_delete: :cascade
    add_foreign_key :likes, :users, on_delete: :cascade
  end
end
