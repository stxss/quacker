class MutedWord < ApplicationRecord
  belongs_to :muter, class_name: "Account"
end
