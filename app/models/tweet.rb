class Tweet < ApplicationRecord
  include Relevance
  include Reusable

  before_validation :validate_urls
  validates :body, length: {in: 1..10000, message: "The tweet has to have at least a single character and no more than 280 characters."}, unless: :retweet?
  validates :body, format: {without: /\A\s*\z/, message: "cannot have only whitespace"}, unless: :retweet?

  belongs_to :author, class_name: "User", foreign_key: :user_id, counter_cache: true

  has_many :comments, class_name: "Comment", foreign_key: :parent_id
  has_many :quote_tweets, class_name: "Quote", foreign_key: :quoted_tweet_id
  has_many :retweets, class_name: "Retweet", foreign_key: :retweet_original_id, dependent: :delete_all
  has_many :likes, dependent: :delete_all

  has_many :notifications, dependent: :delete_all

  has_many :bookmarks, dependent: :delete_all
  has_many :bookmarking_users, through: :bookmarks, dependent: :destroy, source: :user

  # scope :ordered, -> { order(updated_at: :desc) }
  default_scope { where(deleted_at: nil) }
  scope :with_deleted, -> { unscope(where: :deleted_at) }

  def liked_by?(user)
    likes.where(user: user).exists?
  end

  def like(user)
    likes.where(user: user).first_or_create
  end

  def unlike(user)
    likes.where(user: user).destroy_all
  end

  def bookmarked_by?(user)
    bookmarks.where(user: user).exists?
  end

  def bookmark(user)
    bookmarks.where(user: user).first_or_create
  end

  def unbookmark(user)
    bookmarks.where(user: user).destroy_all
  end

  def retweet?
    type == "Retweet"
  end

  def quote_tweet?
    type == "Quote"
  end

  def comment?
    type == "Comment"
  end

  def new_tweet?(timeline_tweets)
    if comment?
      timeline_tweets.none? { |tweet| (tweet.created_at >= created_at) && !tweet.comment? }
    end
  end

  def just_updated?
    updated_at >= Time.now - 1.seconds
  end

  def find_root
    return id if !comment?
    original ? original.find_root : original.root
  end

  def find_depth
    return 0 unless respond_to?(:original)

    to_check = if !original
      Tweet.with_deleted.find(parent_id)
    else
      original
    end
    comment? ? to_check.find_depth + 1 : 0
  end

  def find_height
    return 0 if comments.empty?
    heights = comments.map { |c| c.find_height }
    1 + heights.max
  end

  def update_tree
    update(height: find_height, depth: find_depth)
    original&.update_tree if respond_to?(:original)
  end

  def soft_destroy
    update(deleted_at: Time.now) if has_attribute?(:deleted_at)
  end

  def clean_up(to_destroy = [])
    return unless comment?
    @to_destroy ||= to_destroy
    if !deleted_at.nil?
      @to_destroy << self
      to_check = Tweet.with_deleted.find(parent_id)
    end
    to_check&.clean_up(@to_destroy)
    @to_destroy.each { |t| t.destroy }
  end

  def self.ransackable_attributes(auth_object = nil)
    ["body"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["author"]
  end
end
