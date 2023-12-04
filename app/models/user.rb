class User < ApplicationRecord
  attr_writer :login

  before_create :set_default_display_name
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
  has_many :notifieds, through: :notifications_given

  has_many :notifications_received, class_name: "Notification", foreign_key: "notified_id", dependent: :destroy
  has_many :notifiers, through: :notifications_received

  has_many :created_posts, class_name: "Post", dependent: :destroy
  has_many :created_reposts, class_name: "Repost"
  has_many :created_comments, class_name: "Comment"
  has_many :created_quotes, class_name: "Quote"

  has_many :likes, class_name: "Like", dependent: :destroy

  has_many :bookmarks, class_name: "Bookmark", dependent: :destroy
  has_many :bookmarked_posts, through: :bookmarks, dependent: :destroy, source: :post

  has_one :account, dependent: :destroy

  has_many :created_conversations, class_name: "Conversation", foreign_key: "creator_id"

  has_many :conversation_members, class_name: "ConversationMember", foreign_key: "member_id", dependent: :destroy
  has_many :conversations, through: :conversation_members

  has_many :sent_messages, class_name: "Message", foreign_key: "sender_id", dependent: :destroy

  # only allow letter, number, underscore and punctuation.
  validates_format_of :username, with: /^[a-zA-Z0-9_]*$/, multiline: true

  validate :validate_username
  validates :username, presence: true, uniqueness: true, length: {in: 4..15}

  def follow(other)
    active_follows.build(followed_id: other[:followed_id].to_i, is_request: other[:is_request])
  end

  def unfollow(other)
    active_follows.find_by(followed_id: other.id).delete
    other.notifications_received.where(notifier_id: id, notified_id: other.id, notification_type: :follow).delete_all
  end

  def decline_follow_request(other)
    passive_follows.where(follower_id: other.id).delete_all
  end

  def accept_follow_request(other)
    passive_follows.where(follower_id: other.id).update(is_request: false)
  end

  def following?(other)
    following.include?(other) && other.passive_follows.exists?(follower_id: id, is_request: false)
  end

  def sent_pending_request?(other)
    following.include?(other) && other.passive_follows.exists?(follower_id: id, is_request: true)
  end

  def notify(other_id, type, post_id: nil)
    return if id == other_id

    notification_params = {
      notifier_id: id,
      notified_id: other_id,
      notification_type: type
    }

    notification_params[:post_id] = post_id if post_id
    notifications_given.create(notification_params)
  end

  # all posts that are not comments and current user is passed for reference
  def all_posts(current)
    @normal = created_posts.includes(author: :account).where(type: nil)
    @quotes = created_quotes.includes(original: [author: :account], author: :account)
    @reposts = created_reposts.includes(original: [author: :account], author: :account)

    @posts = (@normal + @quotes + @reposts - created_comments).reject { |post| (post.type == "Repost" && post.original && post.original.author.account.has_blocked?(current)) }.sort_by(&:updated_at)&.reverse
  end

  def all_likes(current, bypass: false)
    likes.includes(post: {author: :account}).order(created_at: :desc).reject do |like|
      author_block_current = like.post.author.account.has_blocked?(current)
      current_blocked_author = bypass ? false : current.account.has_blocked?(like.post.author)
      not_follow_private_author = like.post.author.account.private_visibility ? current.following?(like.post.author) == false : false

      author_block_current || current_blocked_author || not_follow_private_author
    end
  end

  def all_replies
    created_comments.includes(original: [author: :account], author: :account).sort_by(&:updated_at)
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

  def set_default_display_name
    self.display_name = username
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[username display_name]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[created_posts created_quotes created_comments]
  end
end
