class TweetsController < ApplicationController
  def index
    following_ids = "SELECT followed_id FROM follows WHERE follower_id = :current_user_id"
    @tweets = Tweet.where("user_id = :current_user_id OR user_id IN (#{following_ids})", current_user_id: current_user.id)
  end

  def show
    @tweet = Tweet.find(params[:id])
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

  def retweet
    # @retweet = current_user.created_tweets.build(retweet_id: retweet_params[:retweet_id])
    @retweet = current_user.created_tweets.build(retweet_params)
    # body: retweet_params[:retweet_body], retweet_id: retweet_params[:retweet_id]
    if @retweet.save
      redirect_to root_path
    else
      redirect_to request.referrer, alert: "Couldn't retweet"
    end
  end

  def destroy
    @tweet = Tweet.find(params[:id])
    @tweet.destroy
  end

  private

  def tweet_params
    params.require(:tweet).permit(:body)
  end

  def retweet_params
    params.require(:retweet).permit(:retweet_id)
  end
end
