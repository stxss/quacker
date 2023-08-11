class Retweet < Tweet
  belongs_to :og_tweet, class_name: "Tweet", foreign_key: :retweet_id, counter_cache: :retweets_count, optional: true
end
