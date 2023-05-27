class VisibilityFromEnumToBoolean < ActiveRecord::Migration[7.0]
  def change
    remove_column :accounts, :visibility
    add_column :accounts, :private_visibility, :boolean, default: false
  end
end
