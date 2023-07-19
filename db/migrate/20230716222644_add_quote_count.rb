class AddQuoteCount < ActiveRecord::Migration[7.0]
  def change
    add_column :tweets, :quote_tweets_count, :integer
  end
end
