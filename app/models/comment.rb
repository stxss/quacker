class Comment < Post
  after_create -> { update_relevance(:comment, :create, original, root) }
  before_destroy -> { update_relevance(:comment, :destroy, original, root) }

  belongs_to :original, class_name: "Post", foreign_key: :parent_id, counter_cache: :comments_count, optional: true
  belongs_to :root, class_name: "Post", foreign_key: :root_id, optional: true

  default_scope { unscope(where: :deleted_at) }
  scope :with_deleted, -> { unscope(where: :deleted_at) }
  scope :by_relevance, -> { order(relevance: :desc, created_at: :desc) }
end
