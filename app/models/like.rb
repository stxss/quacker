class Like < ApplicationRecord
  include Relevance

  after_create -> { update_relevance(:like, :create, tweet) }
  before_destroy -> { update_relevance(:like, :destroy, tweet) }

  belongs_to :user, counter_cache: :likes_count
  belongs_to :tweet, counter_cache: :likes_count
end
