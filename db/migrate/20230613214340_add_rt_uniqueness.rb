class AddRtUniqueness < ActiveRecord::Migration[7.0]
  def change
    add_index :tweets, [:user_id, :retweet_id], unique: true
  end
end
