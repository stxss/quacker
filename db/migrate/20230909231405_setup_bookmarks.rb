class SetupBookmarks < ActiveRecord::Migration[7.0]
  def change
    create_table :bookmarks do |t|
      t.references :tweet, foreign_key: true, unique: true, null: false
      t.references :user, foreign_key: true, unique: true, null: false

      t.timestamps
    end
  end
end
