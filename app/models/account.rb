class Account < ApplicationRecord
  belongs_to :user
  validates :user_id, presence: true

  enum visibility: {
    public_visibility:  0,
    private_visibility: 1
  }

  enum photo_tagging: {
    turned_off:  0,
    anyone_can_tag: 1,
    only_people_you_follow: 2
  }


end
