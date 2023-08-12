class Tweet < ApplicationRecord
  before_validation :sanitize_body
  validates :body, length: {in: 1..280, message: "The tweet has to have at least a single character and no more than 280 characters."}, unless: :retweet?
  validates :body, format: {without: /\A\s*\z/, message: "cannot have only whitespace"}, unless: :retweet?

  belongs_to :author, class_name: "User", foreign_key: :user_id, counter_cache: true

  has_many :comments, class_name: "Comment", foreign_key: :parent_tweet_id
  has_many :quote_tweets, class_name: "Quote", foreign_key: :quoted_retweet_id
  has_many :retweets, class_name: "Retweet", foreign_key: :retweet_id, dependent: :destroy
  has_many :likes

  scope :ordered, -> { order(updated_at: :desc) }

  def retweet?
    !body? && retweet_id?
  end

  def quote_tweet?
    body? && quoted_retweet_id?
  end

  def comment?
    parent_tweet_id?
  end

  def new_tweet?(timeline_tweets)
    if comment?
      timeline_tweets.none? { |tweet| (tweet.created_at >= created_at) && !tweet.comment? }
    end
  end

  def just_updated?
    updated_at >= Time.now - 1.seconds
  end

  # Ensures that client-side and server-side character count is the same by removing escape sequences and special characters
  def sanitize_body
    self.body = body.gsub(/\\r\\n|\n|\r/, ' ').strip if body
  end
end
