class Tweet < ApplicationRecord
  belongs_to :user
  has_many :likes

  has_many :comments, class_name: "Tweet", foreign_key: "parend_id"
  belongs_to :parent, class_name: "Tweet", optional: true
end
