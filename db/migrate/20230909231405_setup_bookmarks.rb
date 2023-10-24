class SetupBookmarks < ActiveRecord::Migration[7.0]
  def change
    create_table :bookmarks do |t|
      t.references :tweet, unique: true, null: false
      t.references :user, unique: true, null: false

      t.timestamps
    end

    add_foreign_key :bookmarks, :tweets, on_delete: :cascade
    add_foreign_key :bookmarks, :users, on_delete: :cascade
  end
end
