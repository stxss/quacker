class Tweet < ApplicationRecord
  belongs_to :author, class_name: "User", foreign_key: :user_id
  has_many :likes

  default_scope { order(created_at: :desc) }

  has_many :comments, class_name: "Tweet", foreign_key: "parend_id"
  belongs_to :parent, class_name: "Tweet", optional: true
end
