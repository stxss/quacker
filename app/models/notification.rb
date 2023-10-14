class Notification < ApplicationRecord
  enum notification_type: {
    follow: 0,
    like: 1,
    comment: 2,
    retweet: 3,
    quote: 4
  }

  belongs_to :notifier, class_name: "User", counter_cache: true
  belongs_to :notified, class_name: "User", counter_cache: true
  belongs_to :tweet, class_name: "Tweet", optional: true

  scope :ordered, -> { order(updated_at: :desc) }
end
