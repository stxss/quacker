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
    end
  end

  def retweet
    @tweet = Tweet.find(retweet_params[:retweet_id])

    if @tweet.author.account.private_visibility && current_user != @tweet.author
      redirect_to request.referrer, alert: "Couldn't retweet"
      return
    end

    @retweet = current_user.created_tweets.build(retweet_params)

    respond_to do |format|
      if @retweet.save
          format.turbo_stream {
            render turbo_stream: [
              turbo_stream.update("retweet_count_#{@tweet.id}", partial: "tweets/retweet_count", locals: {t: @tweet}),
              turbo_stream.update("retweet_#{@tweet.id}", partial: "tweets/drop_menu", locals: {t: @tweet})
            ]
          }
      format.html { redirect_to request.referrer }
      current_user.notify(@tweet.author.id, :retweet, tweet_id: @tweet.id)
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

  def compose_modal
    @tweet = Tweet.find(params[:quote_tweet][:retweet_id])
  end

  def quote_tweet
    @quote_tweet = current_user.created_tweets.build(quote_tweet_params)
    @tweet = Tweet.find(quote_tweet_params[:retweet_id])

    respond_to do |format|
      if @retweet.save
        format.turbo_stream {
          render turbo_stream: [
            turbo_stream.update("retweet_count_#{@tweet.id}", partial: "tweets/retweet_count", locals: {t: @tweet}),
            turbo_stream.update("retweet_#{@tweet.id}", partial: "tweets/drop_menu", locals: {t: @tweet})
          ]
        }
        format.html { redirect_to request.referrer }
        current_user.notify(@tweet.author.id, :retweet, tweet_id: @tweet.id)
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
      @tweet.author.notifications_received.where(notifier_id: current_user.id, notification_type: :retweet, tweet_id: @tweet.id).destroy_all
    end
  end

  def destroy_retweet
    @tweet = current_user.created_tweets.find_by(retweet_id: retweet_params[:retweet_id])
    @og = Tweet.find(@tweet.retweet_id)

    @tweet.destroy

    @button_update = if (@og.author.account.private_visibility && current_user != @og.author)
      turbo_stream.update("retweet_#{@og.id}", partial: "tweets/fake_retweet_menu", locals: {t: @og})
    else
      turbo_stream.update("retweet_#{@og.id}", partial: "tweets/drop_menu", locals: {t: @og})
    end

    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.remove("tweet_#{@tweet.id}"),
          @button_update,
          turbo_stream.update("retweet_count_#{@og.id}", partial: "tweets/retweet_count", locals: {t: @og})
        ]
      }

      format.html { redirect_to request.referrer }
      @tweet.author.notifications_received.where(notifier_id: current_user.id, notification_type: :retweet, tweet_id: @tweet.id).destroy_all
    end
  end

  private

  def tweet_params
    params.require(:tweet).permit(:body)
  end

  def retweet_params
    params.require(:retweet).permit(:retweet_id)
  end

  def quote_tweet_params
    params.require(:quote_tweet).permit(:retweet_id, :body)
  end
end
