class CreateBookmarks < ActiveRecord::Migration[7.0]
  def change
    create_table :bookmarks do |t|
      t.integer :tweet_id, foreign_key: true
      t.integer :user_id, foreign_key: true

      t.index [:tweet_id, :user_id], unique: true

      t.timestamps
    end
  end
end
