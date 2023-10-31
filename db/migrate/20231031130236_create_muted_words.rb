class CreateMutedWords < ActiveRecord::Migration[7.0]
  def change
    create_table :muted_words do |t|
      t.references :muter, null: false
      t.boolean :from_timeline, default: true, null: false
      t.boolean :from_notifications, default: true, null: false
      t.text :body
      t.datetime :expiration, null: true
      t.index [:muter_id, :body], unique: true
      t.timestamps
    end
  end
end
