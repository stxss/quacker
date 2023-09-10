class Comment < Tweet
  after_create -> { update_relevance(:comment, :create, original, root) }
  before_destroy -> { update_relevance(:comment, :destroy, original, root) }
  belongs_to :root, class_name: "Tweet", foreign_key: :root_id, optional: true

  default_scope { unscope(where: :deleted_at) }
  scope :with_deleted, -> { unscope(where: :deleted_at) }
  scope :by_relevance, -> { order(relevance: :desc) }
end
