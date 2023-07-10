class Tweet < ApplicationRecord
  validates :body, length: {in: 1..280, message: "The tweet has to have at least a single character and no more than 280 characters."}, unless: :retweet?
  validates :body, format: {without: /\A\s*\z/, message: "cannot have only whitespace"}, unless: :retweet?

  belongs_to :author, class_name: "User", foreign_key: :user_id, counter_cache: true
  has_many :likes

  has_many :comments, class_name: "Tweet", foreign_key: :parent_tweet_id
  belongs_to :parent, class_name: "Tweet", optional: true, counter_cache: true

  has_many :retweets, class_name: "Tweet", foreign_key: :retweet_id, dependent: :destroy, counter_cache: :retweets_count
  has_many :quote_tweets, class_name: "Tweet", foreign_key: :quoted_retweet_id, dependent: :destroy, counter_cache: :quote_tweets_count

  default_scope { order(updated_at: :desc) }

  def retweet?
    !body && retweet_id
  end

  def quote_tweet?
    body && quoted_retweet_id
  end

  def comment?
    parent_tweet_id?
  end

  def quote
    Tweet.find(quoted_retweet_id)
  end

  def responder
    User.find(Tweet.find(parent_tweet_id).user_id).username
  end

  def original_from_retweet
    Tweet.find(retweet_id)
  end

  def new_tweet?(timeline_tweets)
    if comment?
      timeline_tweets.none? { |tweet| (tweet.created_at >= created_at) && !tweet.comment? }
    end
  end

  def just_updated?
    updated_at >= Time.now - 1.seconds
  end
end
