class UpdateColumnName < ActiveRecord::Migration[7.0]
  def change
    rename_column :notifications, :type, :notification_type
  end
end
