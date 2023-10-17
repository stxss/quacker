class MutedAccount < ApplicationRecord
  belongs_to :muted, class_name: "User", counter_cache: true
  belongs_to :muter, class_name: "User", counter_cache: true
end
