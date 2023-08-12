class Comment < Tweet
  belongs_to :original, class_name: "Tweet", foreign_key: :parent_tweet_id, counter_cache: :comments_count, optional: true
end
