class Comment < Tweet
  after_create :update_relevance
  after_destroy :downgrade_relevance
  belongs_to :original, class_name: "Tweet", foreign_key: :parent_tweet_id, counter_cache: :comments_count, optional: true
  belongs_to :root, class_name: "Tweet", foreign_key: :root_id, optional: true

  default_scope { unscope(where: :deleted_at) }
  scope :with_deleted, -> { unscope(where: :deleted_at) }
  scope :by_relevance, -> { order(relevance: :desc) }

  private

  def update_relevance
    original.update_columns(relevance: original.relevance + 0.85)
    root.update_columns(relevance: root.relevance + 0.85) if original != root
  end

  def downgrade_relevance
    original.update_columns(relevance: original.relevance - 0.85)
    root.update_columns(relevance: root.relevance - 0.85) if original != root
  end
end
