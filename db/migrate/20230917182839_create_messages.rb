class CreateMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :messages do |t|
      t.text :body
      t.references :sender, null: false, foreign_key: {to_table: :users}, unique: true
      t.references :conversation, null: false, foreign_key: true, unique: true
      t.boolean :read, null: false, default: false

      t.timestamps
    end
  end
end
