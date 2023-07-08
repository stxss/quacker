class User < ApplicationRecord
  attr_writer :login

  after_create :create_account

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable

  has_many :active_follows, class_name: "Follow", foreign_key: "follower_id", dependent: :destroy
  has_many :following, through: :active_follows, source: :followed

  has_many :passive_follows, class_name: "Follow", foreign_key: "followed_id", dependent: :destroy
  has_many :followers, through: :passive_follows

  has_many :notifications_given, class_name: "Notification", foreign_key: "notifier_id", dependent: :destroy
  has_many :notifieds, through: :notifications_given, source: :notifier

  has_many :notifications_received, class_name: "Notification", foreign_key: "notified_id", dependent: :destroy
  has_many :notifiers, through: :notifications_received

  has_many :created_tweets, class_name: "Tweet", dependent: :destroy
  has_many :liked_tweets, class_name: "Like", dependent: :destroy

  has_one :account, dependent: :destroy

  # only allow letter, number, underscore and punctuation.
  validates_format_of :username, with: /^[a-zA-Z0-9_]*$/, :multiline => true

  validate :validate_username
  validates :username, presence: true, uniqueness: true, length: { in: 4..15 }

  def follow(other)
    active_follows.create(followed_id: other[:followed_id].to_i, is_request: other[:is_request])
  end

  def unfollow(other)
    active_follows.find_by(followed_id: other.id).destroy
    other.notifications_received.where(notifier_id: id, notified_id: other.id, notification_type: :follow).destroy_all
  end

  def decline_follow_request(other)
    other.active_follows.find_by(follower_id: other.id).destroy
  end

  def accept_follow_request(other)
    passive_follows.update(followed_id: id, is_request: false)
  end

  def following?(other)
    following.include?(other) && other.passive_follows.exists?(follower_id: id, is_request: false)
  end

  def sent_pending_request?(other)
    following.include?(other) && other.passive_follows.exists?(follower_id: id, is_request: true)
  end

  def notify(other_id, type, tweet_id: nil)
    notifications_given.create(notifier_id: id, notified_id: other_id, notification_type: type, tweet_id: tweet_id)
  end

  def like_tweet(other)
    liked_tweets.create(tweet_id: other[:tweet_id].to_i)
  end

  def login
    @login || username || email
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if (login = conditions.delete(:login))
      where(conditions.to_h).where(["lower(username) = :value OR lower(email) = :value", {value: login.downcase}]).first
    elsif conditions.has_key?(:username) || conditions.has_key?(:email)
      where(conditions.to_h).first
    end
  end

  def validate_username
    if User.where(email: username).exists?
      errors.add(:username, :invalid)
    end
  end

  def user_has_rt?(tweet)
    created_tweets.where(retweet_id: tweet).exists?
  end

  def user_has_like?(tweet)
    liked_tweets.where(tweet_id: tweet).exists?
  end
end
