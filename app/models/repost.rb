class Repost < Tweet
  belongs_to :original, -> { unscope(where: :deleted_at) }, class_name: "Tweet", foreign_key: :repost_original_id, counter_cache: :reposts_count, optional: true
  belongs_to :user

  after_create -> { update_relevance(:repost, :create, original) }
  before_destroy -> { update_relevance(:repost, :destroy, original) }
end
