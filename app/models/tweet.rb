class Tweet < ApplicationRecord
  # validates :body, presence: true
  validates :body, length: {in: 1..280,
  message: "The tweet has to have at least a single character and no more than 280 characters."}
  validates :body, format: {without: /\A\s*\z/, message: "cannot have only whitespace"}

  belongs_to :author, class_name: "User", foreign_key: :user_id
  has_many :likes

  default_scope { order(created_at: :desc) }

  has_many :comments, class_name: "Tweet", foreign_key: "parend_id"
  belongs_to :parent, class_name: "Tweet", optional: true
end
