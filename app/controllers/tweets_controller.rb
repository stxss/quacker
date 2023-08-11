class TweetsController < ApplicationController
  class UserGonePrivate < StandardError; end
  class UnauthorizedElements < StandardError; end

  before_action :first_visit?, :set_cache_headers, only: [:index]
  before_action :check_refresh, :session_refresh, only: [:new]
  after_action :refresh_comments, only: [:index]

  def new
    index
    @tweet = Tweet.new
    @retweet = Tweet.find(session[:retweet_id]) if session[:retweet_id].present?
    @comment = Tweet.find(session[:comment]) if session[:comment].present?
  end

  def index
    following_ids = "SELECT followed_id FROM follows WHERE follower_id = :current_user_id AND is_request = false"
    @tweets = Tweet.where("user_id = :current_user_id OR user_id IN (#{following_ids})", current_user_id: current_user.id).includes(:comments, :quote_tweets, :retweets, :likes, :author).ordered.load

    @show_replies = true

    if session[:new_comment]&.< 2
      session[:new_comment] += 1
    elsif session[:new_comment]&.>= 2
      session.delete(:new_comment)
    end
  end

  def show
    @tweet = Tweet.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    @tweet = nil
  end

  def create
    @tweet = if params[:retweet_id]
      current_user.created_tweets.create!(body: tweet_params[:body], quoted_retweet_id: params[:retweet_id])
    elsif params[:parent_tweet_id]
      session[:new_comment] = 0
      current_user.created_comments.create!(body: tweet_params[:body], parent_tweet_id: params[:parent_tweet_id])
    else
      current_user.created_tweets.create!(tweet_params)
    end

    @og = if params[:retweet_id]
      Tweet.find(params[:retweet_id])
    elsif params[:parent_tweet_id]
      Tweet.find(params[:parent_tweet_id])
    end

    if params[:parent_tweet_id]
      @og.broadcast_render_later_to "comments",
        partial: "tweets/update_comments_count",
        locals: {t: Tweet.find(@og.id)}
    elsif params[:retweet_id]
      @og.broadcast_render_later_to "retweets",
        partial: "tweets/update_retweets_count",
        locals: {t: Tweet.find(@og.id)}
    end

    respond_to do |format|
      format.html { redirect_to root_path }
      session[:og_comment_id] = @tweet.id
    end
  end

  def destroy
    @tweet = Tweet.find(params[:id])
    if @tweet.comment?
      parent_tweet = Tweet.find(@tweet.parent_tweet_id)
      parent_tweet.update(updated_at: parent_tweet.created_at)
    end

    if current_user == @tweet.author
      @tweet.destroy
    else
      raise UnauthorizedElements
    end

    @og = if @tweet.retweet?
      @tweet.og_tweet
    elsif @tweet.quote_tweet?
      @tweet.quote
    elsif @tweet.comment?
      parent_tweet
    end

    if @tweet.retweet? || @tweet.quote_tweet?
      @og.broadcast_render_later_to "retweets",
        partial: "tweets/update_retweets_count",
        locals: {t: Tweet.find(@og.id)}
    elsif @tweet.comment?
      @og.broadcast_render_later_to "comments",
        partial: "tweets/update_comments_count",
        locals: {t: Tweet.find(@og.id)}
    end

    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.replace_all("#tweet_#{@tweet.id}.quoted ", partial: "tweets/unavailable_tweet"),
          turbo_stream.remove_all(".retweets retweets_#{@tweet.id}"),
          turbo_stream.remove("tweet_#{@tweet.id}")
        ]
      }
      format.html { redirect_to request.referrer }
      @tweet.author.notifications_received.where(notifier_id: current_user.id, notification_type: :retweet, tweet_id: @tweet.id).destroy_all
    end
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.remove("tweet_#{params[:id]}"),
          flash.now[:alert] = "Something went wrong, please try again!"
        ]
      }
    end
  rescue NoMethodError
    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.remove("tweet_#{params[:id]}"),
          flash.now[:alert] = "Something went wrong, please try again!"
        ]
      }
    end
  rescue UnauthorizedElements
    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.replace_all("tweet_#{params[:id]}", partial: "tweets/single_tweet", locals: {t: @tweet}),
          flash.now[:alert] = "Something went wrong, please try again!"
        ]
      }
    end
  end

  # For the generation of the tweet button
  def tweet_btn
    @button = if params[:valid] == "1"
      "tweets/tweet_btn"
    elsif params[:valid] == "0"
      "tweets/fake_tweet_btn"
    end

    respond_to do |format|
      format.turbo_stream
    end
  end

  private

  def tweet_params
    params.require(:tweet).permit(:body, :quoted_retweet_id)
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

  def refresh_comments
    return if !session[:new_comment]

    # THIS IS THE COMMENT
    comment = Comment.find_by(id: session[:og_comment_id])

    # THIS IS THE PARENT COMMENT
    comment&.parent&.update(updated_at: comment.created_at)

    session.delete(:og_comment_id)
  end
end
