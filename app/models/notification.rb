class Notification < ApplicationRecord
  enum notification_type: {
    follow:  0,
    like:    1,
    reply:   2,
    retweet: 3
  }

  belongs_to :notifier, class_name: "User", counter_cache: true
  belongs_to :notified, class_name: "User", counter_cache: true
  belongs_to :tweet, class_name: "Tweet"

  validates :notifier_id, presence: true
  validates :notified_id, presence: true

  scope :ordered, -> { order(updated_at: :desc) }
end
