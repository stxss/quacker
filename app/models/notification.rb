class Notification < ApplicationRecord
  enum notification_type: {
    follow_request: 0,
    follow:         1,
    like:           2,
    reply:          3,
    retweet:        4
  }

  belongs_to :notifier, class_name: "User"
  belongs_to :notified, class_name: "User"

  validates :notifier_id, presence: true
  validates :notified_id, presence: true

end
