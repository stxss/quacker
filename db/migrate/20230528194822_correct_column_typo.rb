class CorrectColumnTypo < ActiveRecord::Migration[7.0]
  def change
    rename_column :accounts, :hide_potentially_sentitive_content, :hide_potentially_sensitive_content
  end
end
