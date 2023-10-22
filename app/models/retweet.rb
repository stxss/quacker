class Retweet < Tweet
  belongs_to :original, -> { unscope(where: :deleted_at) }, class_name: "Tweet", foreign_key: :retweet_original_id, counter_cache: :retweets_count, optional: true

  after_create -> { update_relevance(:retweet, :create, original) }
  before_destroy -> { update_relevance(:retweet, :destroy, original) }
end
