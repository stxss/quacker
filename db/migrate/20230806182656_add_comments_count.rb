class AddCommentsCount < ActiveRecord::Migration[7.0]
  def change
    add_column :tweets, :comments_count, :integer
  end
end
