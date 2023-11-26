class Quote < Post
  belongs_to :original, -> { unscope(where: :deleted_at) }, class_name: "Post", foreign_key: :quoted_post_id, counter_cache: :quote_posts_count, optional: true
  belongs_to :user

  after_create -> { update_relevance(:quote, :create, original) }
  before_destroy -> { update_relevance(:quote, :destroy, original) }
end
