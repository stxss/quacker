class UpdateUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :display_name, :string
    add_column :users, :visibility, :integer, default: 0
  end
end
