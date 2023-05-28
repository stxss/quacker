class Account < ApplicationRecord
  belongs_to :user
  validates :user_id, presence: true

  enum allow_media_tagging: {turned_off: 0, anyone_can_tag: 1, only_people_you_follow: 2}, _prefix: true
end
