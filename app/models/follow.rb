class Follow < ApplicationRecord
  belongs_to :follower, class_name: "User", counter_cache: true
  belongs_to :followed, class_name: "User", counter_cache: true
end
