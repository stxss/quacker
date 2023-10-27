class Message < ApplicationRecord
  include Reusable
  include PgSearch::Model
  pg_search_scope :search, against: :body, using: {
    tsearch: {
      dictionary: "english",
      prefix: true
    }
  }

  validates :body, presence: true
  validates :body, length: {minimum: 1, message: "Can't send an empty message"}
  validate :sender_isnt_blocked

  belongs_to :sender, class_name: "User"
  belongs_to :conversation, counter_cache: true
  scope :unread, -> { where(read: false) }
  scope :ordered, -> { order(created_at: :asc) }

  def sender_isnt_blocked
    if conversation.members.size == 2
      receiver = conversation.members.excluding(sender).first
      if receiver.account.has_blocked?(sender)
        errors.add(:base, "You can no longer send messages to @#{receiver.username} as they have blocked you.")
      end
    end
  end
end
