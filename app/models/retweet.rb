class Retweet < ApplicationRecord
  belongs_to :user

  # If quote tweet it can have likes
  # has_many :likes

end
