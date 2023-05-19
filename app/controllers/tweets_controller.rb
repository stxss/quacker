class TweetsController < ApplicationController
  def index
    @tweets = Tweet.all
  end

  def new
    @tweet = Tweet.new
  end

  def create
    @tweet = current_user.created_tweets.build(tweet_params)

    if @tweet.save
      redirect_to root_path
    else
      flash.now[:alert] = "Oops, something went wrong, check your fields again"
      render :index, status: :unprocessable_entity
    end
  end

  private

  def tweet_params
    params.require(:tweet).permit(:body, :parent_id)
  end
end
