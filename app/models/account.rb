class Account < ApplicationRecord
  belongs_to :user

  has_many :muted_accounts, class_name: "MutedAccount", foreign_key: "muter_id", dependent: :destroy
  has_many :blocked_accounts, class_name: "Block", foreign_key: "blocker_id", dependent: :destroy

  enum allow_media_tagging: {turned_off: 0, anyone_can_tag: 1, only_people_you_follow: 2}, _prefix: true

  def has_muted?(other)
    muted_accounts.where(muted_id: other.id).exists?
  end

  def mute(other)
    muted_accounts.create(muted_id: other[:muted_id].to_i)
  end

  def has_blocked?(other)
    blocked_accounts.where(blocked_id: other.id).exists?
  end

  def block(other)
    blocked_accounts.create(blocked_id: other[:blocked_id].to_i)
  end
end
