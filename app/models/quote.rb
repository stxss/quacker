class Quote < Tweet
  belongs_to :original, -> { unscope(where: :deleted_at) }, class_name: "Tweet", foreign_key: :quoted_tweet_id, counter_cache: :quote_tweets_count, optional: true

  after_create -> { update_relevance(:quote, :create, original) }
  before_destroy -> { update_relevance(:quote, :destroy, original) }
end
