class UpdateTweetTypes < ActiveRecord::Migration[7.0]
  def change
    Tweet.where(parent_tweet_id: nil, retweet_id: nil, quoted_retweet_id: nil).update_all(type: nil)
    Tweet.where.not(parent_tweet_id: nil).update_all(type: "Comment")
    Tweet.where.not(retweet_id: nil).update_all(type: "Retweet")
    Tweet.where.not(quoted_retweet_id: nil).update_all(type: "Quote")
  end
end
