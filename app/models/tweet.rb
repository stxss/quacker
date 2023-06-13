class Tweet < ApplicationRecord
  # validates :body, presence: true
  validates :body, length: {in: 1..280,
  message: "The tweet has to have at least a single character and no more than 280 characters."}, unless: :retweet?
  validates :body, format: {without: /\A\s*\z/, message: "cannot have only whitespace"}, unless: :retweet?
  # validates :body, presence: true, format: , unless: :retweet?

  belongs_to :author, class_name: "User", foreign_key: :user_id, counter_cache: true
  has_many :likes

  has_many :comments, class_name: "Tweet", foreign_key: "parent_id"
  belongs_to :parent, class_name: "Tweet", optional: true, counter_cache: true

  has_many :retweets, class_name: "Tweet", foreign_key: :retweet_id, dependent: :destroy

  validates :retweet_id, uniqueness: { scope: :user_id }

  default_scope { order(created_at: :desc) }

  def retweet?
    !retweet_id.nil?
  end
end
