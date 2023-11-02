class CreateBlocks < ActiveRecord::Migration[7.0]
  def change
    create_table :blocks do |t|
      t.references :blocker, null: false
      t.references :blocked, null: false
      t.index [:blocker_id, :blocked_id], unique: true

      t.timestamps
    end

    add_column :accounts, :blocks_count, :integer, null: false, default: 0
  end
end
