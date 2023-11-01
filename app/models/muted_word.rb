class MutedWord < ApplicationRecord
  belongs_to :muter, class_name: "Account"
  validates :body, presence: true
end
