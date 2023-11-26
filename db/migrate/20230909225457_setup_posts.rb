class SetupPosts < ActiveRecord::Migration[7.0]
  def change
    create_table :posts do |t|
      t.string :type

      t.text :body
      t.references :user, unique: true, null: false

      t.references :parent
      t.references :repost_original
      t.references :quoted_post, default: nil

      t.integer :reposts_count, null: false, default: 0
      t.integer :likes_count, null: false, default: 0
      t.integer :comments_count, null: false, default: 0
      t.integer :quote_posts_count, null: false, default: 0
      t.integer :bookmarks_count, null: false, default: 0

      t.references :root, default: nil
      t.integer :height, default: 0
      t.integer :depth, default: 0

      t.decimal :relevance, default: 0.0

      t.datetime :deleted_at, default: nil
      t.timestamps
    end

    add_foreign_key :posts, :posts, column: :root_id
    add_foreign_key :posts, :posts, column: :parent_id
    add_foreign_key :posts, :posts, column: :repost_original_id, on_delete: :cascade
    add_foreign_key :posts, :posts, column: :quoted_post_id, on_delete: :nullify
    add_foreign_key :posts, :users, on_delete: :cascade
  end
end
