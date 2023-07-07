class TweetsController < ApplicationController
  before_action :first_visit?, :set_cache_headers, only: [:index]
  before_action :check_refresh, :session_refresh, only: [:new]

  def new
    index
    @tweet = Tweet.new
    @retweet = Tweet.find(session[:retweet_id]) if session[:retweet_id].present?
    @comment = Tweet.find(session[:comment]) if session[:comment].present?
  end

  def index
    following_ids = "SELECT followed_id FROM follows WHERE follower_id = :current_user_id"
    @tweets = Tweet.where("user_id = :current_user_id OR user_id IN (#{following_ids})", current_user_id: current_user.id)
    @show_replies = true
  end

  def show
    @tweet = Tweet.find(params[:id])
  end

  def create
    @tweet = if params[:retweet_id]
      current_user.created_tweets.build(body: tweet_params[:body], quoted_retweet_id: params[:retweet_id])
    elsif params[:parent_tweet_id]
      current_user.created_tweets.build(body: tweet_params[:body], parent_tweet_id: params[:parent_tweet_id])
    else
      current_user.created_tweets.build(tweet_params)
    end

    respond_to do |format|
      if @tweet.save
        format.html { redirect_to root_path }
      end
    end
  end

  def retweet
    @tweet = Tweet.find(retweet_params[:retweet_id])

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
    params.require(:tweet).permit(:body, :quoted_retweet_id)
  end

  def retweet_params
    params.require(:retweet).permit(:retweet_id)
  end

  def first_visit?
    session[:first_visit] = current_user.sign_in_count == 1 && session[:first_visit].nil?
  end

  def check_refresh
    if (session[:last_request] == "GET" && request.method == "POST") || request.method == "POST"
      session[:refresh] = true
    elsif (session[:last_request] == "POST" && request.method == "GET") || session[:last_request] == "GET" && request.method == "GET"
      session[:refresh] = false
    end
    session[:last_request] = request.method
  end

  def set_cache_headers
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

  def session_refresh
    session.delete(:retweet_id) if session[:retweet_id].present?
    session.delete(:comment) if session[:comment].present?

    session[:retweet_id] = params[:retweet_id] if params[:retweet_id].present?
    session[:comment] = params[:parent_tweet_id] if params[:parent_tweet_id].present?
  end
end
