class Retweet < Tweet
  belongs_to :original, class_name: "Tweet", foreign_key: :retweet_original_id, counter_cache: :retweets_count, optional: true
end
