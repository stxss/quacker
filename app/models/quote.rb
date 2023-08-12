class Quote < Tweet
  belongs_to :original, class_name: "Tweet", foreign_key: :quoted_retweet_id, counter_cache: :quote_tweets_count, optional: true
end