class User < ApplicationRecord
  attr_writer :login

  enum visibility: {
    public_visibility:  0,
    private_visibility: 1
  }

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :active_follows, class_name: "Follow", foreign_key: "follower_id", dependent: :destroy
  has_many :following, through: :active_follows, source: :followed

  has_many :passive_follows, class_name: "Follow", foreign_key: "followed_id", dependent: :destroy
  has_many :followers, through: :passive_follows

  has_many :created_tweets, class_name: "Tweet", dependent: :destroy
  # has_many :liked_tweets, dependent: :destroy
  # has_many :retweets, dependent: :destroy

  # only allow letter, number, underscore and punctuation.
  validates_format_of :username, with: /^[a-zA-Z0-9_\.]*$/, :multiline => true

  validate :validate_username

  def follow(other)
    active_follows.create(followed_id: other[:followed_id].to_i)
  end

  def unfollow(other)
    active_follows.find_by(followed_id: other.id).destroy
  end

  def follows?(other)
    following.include?(other)
  end

  private

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
end
