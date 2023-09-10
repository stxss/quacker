class Quote < Tweet
  after_create -> { update_relevance(:comment, :create, original) }
  before_destroy -> { update_relevance(:comment, :destroy, original) }
  belongs_to :original, class_name: "Tweet", foreign_key: :quoted_tweet_id, counter_cache: :quote_tweets_count, optional: true
end
