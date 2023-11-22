class Bookmark < ApplicationRecord
  belongs_to :user, counter_cache: :bookmarks_count
  belongs_to :tweet, counter_cache: :bookmarks_count
end
