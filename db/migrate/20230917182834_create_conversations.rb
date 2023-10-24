class CreateConversations < ActiveRecord::Migration[7.0]
  def change
    create_table :conversations do |t|
      t.references :creator, null: false, foreign_key: {to_table: :users}, unique: true
      t.text :name, optional: true
      t.integer :messages_count, null: false, default: 0

      t.timestamps
    end

    create_table :conversation_members, id: false do |t|
      t.references :conversation, null: false
      t.references :member, null: false
      t.boolean :left, null: false, default: false

      t.timestamps
    end

    add_foreign_key :conversation_members, :conversations, on_delete: :cascade
    add_foreign_key :conversation_members, :users, column: :member_id, on_delete: :cascade
  end
end
