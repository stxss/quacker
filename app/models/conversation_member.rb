class ConversationMember < ApplicationRecord
  self.primary_key = :member_id

  belongs_to :member, class_name: "User"
  belongs_to :conversation
end
