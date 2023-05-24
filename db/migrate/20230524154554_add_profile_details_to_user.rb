class AddProfileDetailsToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :biography, :string
    add_column :users, :location, :string
    add_column :users, :website, :string
    add_column :users, :birth_date, :date
    remove_column :users, :visibility
  end
end
