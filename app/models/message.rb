class Message < ApplicationRecord
  validates :body, presence: true
  validates :body, length: {minimum: 1, message: "Can't send an empty message"}

  belongs_to :sender, class_name: "User"
  belongs_to :conversation, counter_cache: true
  scope :unread, -> { where(read: false) }
  scope :ordered, -> { order(created_at: :asc) }
end
