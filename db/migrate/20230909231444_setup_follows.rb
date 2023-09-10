class SetupFollows < ActiveRecord::Migration[7.0]
  def change
    create_table :follows do |t|
      t.references :follower, null: false
      t.references :followed, null: false
      t.index [:follower_id, :followed_id], unique: true

      t.boolean :is_request, null: false, default: false

      t.timestamps
    end
  end
end
