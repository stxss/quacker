class Follow < ApplicationRecord
  belongs_to :follower, class_name: "User", counter_cache: true
  belongs_to :followed, class_name: "User", counter_cache: true

  validates :follower_id, presence: true
  validates :followed_id, presence: true
end
