class Block < ApplicationRecord
  belongs_to :blocker, class_name: "Account", counter_cache: true
  belongs_to :blocked, class_name: "Account", counter_cache: true
end
