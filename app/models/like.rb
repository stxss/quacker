class Like < ApplicationRecord
  include Relevance

  after_create -> { update_relevance(:like, :create, post) }
  before_destroy -> { update_relevance(:like, :destroy, post) }

  belongs_to :user, counter_cache: :likes_count
  belongs_to :post, counter_cache: :likes_count
end
