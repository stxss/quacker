class TweetsController < ApplicationController
  def index
    following_ids = "SELECT followed_id FROM follows WHERE follower_id = :current_user_id"
    @tweets = Tweet.where("user_id = :current_user_id OR user_id IN (#{following_ids})", current_user_id: current_user.id)
  end

  def create
    @tweet = current_user.created_tweets.build(tweet_params)

    if @tweet.save
      redirect_to root_path
    end
  end

  def retweet
    @retweet = current_user.created_tweets.build(retweet_params)
    @tweet = Tweet.find(retweet_params[:retweet_id])

    respond_to do |format|
      if @retweet.save
        format.turbo_stream {
          render turbo_stream: [
            turbo_stream.update("retweet_count_#{@tweet.id}", partial: "tweets/retweet_count", locals: {t: @tweet}),
            turbo_stream.update("retweet_#{@tweet.id}", partial: "tweets/unretweet_button", locals: {t: @tweet})
          ]
        }
        format.html { redirect_to request.referrer }
        current_user.notify(@tweet.author.id, :retweet, tweet_id: @tweet.id)
      else
        redirect_to request.referrer, alert: "Couldn't retweet"
      end
    end
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.remove("tweet_#{retweet_params[:retweet_id]}"),
          flash.now[:alert] = "Couldn't retweet"
        ]
      }
    end
  end

  def destroy
    @tweet = Tweet.find(params[:id])
    @tweet.destroy

    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.remove("tweet_#{@tweet.id}")
        ]
      }
      format.html { redirect_to request.referrer }
    end
  end

  private

  def tweet_params
    params.require(:tweet).permit(:body)
  end

  def retweet_params
    params.require(:retweet).permit(:retweet_id)
  end
end
