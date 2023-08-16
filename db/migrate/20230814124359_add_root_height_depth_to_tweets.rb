class AddRootHeightDepthToTweets < ActiveRecord::Migration[7.0]
  def change
    add_column :tweets, :root_id, :integer, default: nil
    add_column :tweets, :height, :integer, default: 0
    add_column :tweets, :depth, :integer, default: 0

    Tweet.all.each do |tweet|
      root = find_root(tweet)
      height = find_height(tweet)
      depth = find_depth(tweet)
      tweet.update(root_id: root.id, height: height, depth: depth)
    end
  end

  def find_root(tweet)
    if tweet.comment?
      find_root(tweet.original)
    else
      tweet
    end
  end

  def find_depth(tweet)
    if tweet.comment?
      find_depth(tweet.original) + 1
    else
      0
    end
  end

  def find_height(tweet)
    return 0 if tweet.comments.empty?

    heights = tweet.comments.map { |c| find_height(c) }
    1 + heights.max
  end
end
