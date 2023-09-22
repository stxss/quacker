class CreateConversations < ActiveRecord::Migration[7.0]
  def change
    create_table :conversations do |t|
      t.references :creator, null: false, foreign_key: {to_table: :users}, unique: true
      t.text :name, optional: true

      t.timestamps
    end

    create_table :conversation_members, id: false do |t|
      t.references :conversation, null: false, foreign_key: true
      t.references :member, null: false, foreign_key: {to_table: :users}

      t.timestamps
    end

    # add_index :conversation_members, [:member_id, :conversation_id], unique: true
  end
end
