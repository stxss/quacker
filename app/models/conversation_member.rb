class ConversationMember < ApplicationRecord
  belongs_to :member, class_name: "User"
  belongs_to :conversation
end
