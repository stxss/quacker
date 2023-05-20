class Notification < ApplicationRecord
  enum notification_type: {
    follow_request: 0,
    follow:         1,
    unfollow:       2,
    like:           3,
    reply:          4,
    retweet:        5
  }
end
