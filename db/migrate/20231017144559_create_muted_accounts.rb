class CreateMutedAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :muted_accounts do |t|
      t.references :muter, null: false
      t.references :muted, null: false
      t.index [:muter_id, :muted_id], unique: true

      t.timestamps
    end

    add_column :users, :muted_accounts_count, :integer, null: false, default: 0
  end
end
