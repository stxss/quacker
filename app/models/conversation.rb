class Conversation < ApplicationRecord
  belongs_to :creator, class_name: "User"

  has_many :conversation_members, dependent: :destroy
  has_many :members, class_name: "User", foreign_key: :user_id, through: :conversation_members
  has_many :messages, dependent: :destroy

  before_create :validate_group_name
  before_create :validate_minimum_members

  # validates :conversation_members, uniqueness: {scope: :conversation_id}
  scope :ordered, -> { order(updated_at: :desc) }
  scope :members, -> { members }
  scope :member_ids, -> { members.map(&:id) }

  private

  def validate_group_name
    if members.size > 2 && name.blank?
      errors.add(:name, "must be present when there are 2 or more members")
    end
  end

  def validate_minimum_members
    if members.size < 2
      errors.add(:members, "must be at least 2")
    end
  end
end

# Handle error messages with flash messages
