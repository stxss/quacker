class TweetsController < ApplicationController
  def index
    following_ids = "SELECT followed_id FROM follows WHERE follower_id = :current_user_id"
    @tweets = Tweet.where("user_id = :current_user_id OR user_id IN (#{following_ids})", current_user_id: current_user.id)
  end

  def create
    @tweet = current_user.created_tweets.build(tweet_params)

    if @tweet.save
      redirect_to root_path
    else
      flash[:alert] = "Oops, something went wrong, check your fields again"
      redirect_to request.referrer
    end
  end

  private

  def tweet_params
    params.require(:tweet).permit(:body, :parent_id)
  end
end
