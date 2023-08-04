class Like < ApplicationRecord
  belongs_to :tweet, counter_cache: :likes_count
  belongs_to :user, counter_cache: true

  after_save_commit do
    broadcast_like
  end

  def broadcast_like
    broadcast_render_later_to "public_likes",
      partial: "likes/update_likes_count",
      locals: {t: Tweet.find(tweet.id)}
  end
end
