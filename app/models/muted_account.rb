class MutedAccount < ApplicationRecord
  belongs_to :muted, class_name: "Account", counter_cache: true
  belongs_to :muter, class_name: "Account", counter_cache: true
end
