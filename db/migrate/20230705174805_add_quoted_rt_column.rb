class AddQuotedRtColumn < ActiveRecord::Migration[7.0]
  def change
    add_column :tweets, :quoted_retweet_id, :integer, default: nil
  end
end
