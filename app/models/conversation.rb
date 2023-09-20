class Conversation < ApplicationRecord
  belongs_to :creator, class_name: "User"

  has_many :conversation_members, dependent: :destroy
  has_many :members, class_name: "User", foreign_key: :user_id, through: :conversation_members
  has_many :messages, dependent: :destroy

  validate :group_name_presence_if_multiple_members

  private

  def group_name_presence_if_multiple_members
    p members
    if members.size > 2 && name.blank?
      errors.add(:name, "must be present when there are 2 or more members")
    end
  end
end
