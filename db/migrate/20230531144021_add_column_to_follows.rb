class AddColumnToFollows < ActiveRecord::Migration[7.0]
  def change
    add_column :follows, :is_request, :boolean, default: false, null: false
  end
end
