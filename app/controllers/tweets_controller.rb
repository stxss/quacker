class TweetsController < ApplicationController
  class UserGonePrivate < StandardError; end

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
    following_ids = "SELECT followed_id FROM follows WHERE follower_id = :current_user_id"
    @tweets = Tweet.where("user_id = :current_user_id OR user_id IN (#{following_ids})", current_user_id: current_user.id).includes(:parent, :quote_tweets, :retweets, :likes, :author).ordered.load

    @show_replies = true

    if session[:new_comment]&.< 2
      session[:new_comment] += 1
    elsif session[:new_comment]&.>= 2
      session.delete(:new_comment)
    end
  end

  def show
    @tweet = Tweet.find(params[:id])
  end

  def create
    @tweet = if params[:parent_tweet_id]
      session[:new_comment] = 0
      current_user.created_tweets.create!(body: tweet_params[:body], parent_tweet_id: params[:parent_tweet_id])
      @og = Tweet.find(params[:parent_tweet_id])
    else
      current_user.created_tweets.create!(body: tweet_params[:body], quoted_retweet_id: params[:retweet_id])
      @og = Tweet.find(params[:retweet_id])
    end

    @og.broadcast_render_later_to "retweets",
      partial: "tweets/update_retweets_count",
      locals: {t: Tweet.find(@og.id)}

    respond_to do |format|
      format.html { redirect_to root_path }
      session[:og_comment_id] = @tweet.id
    end
  end

  def retweet
    # When user clicks retweet, it looks up the tweet, creates a retweet and then broadcasts the updated count to all the users. Finally, to update the buttons correctly for the user, a format.turbo_stream request is made with the value of the tweet as the original has been updated with a retweet count. By fetching the original tweet after the update, the most recent values are assured and errors minimized

    @retweet = current_user.created_tweets.build(retweet_params)
    @tweet = @retweet.og_tweet || Tweet.find(retweet_params[:retweet_id])

    @tweet.broadcast_render_later_to "retweets",
      partial: "tweets/update_retweets_count",
      locals: {t: Tweet.find(@tweet.id)}

    if @tweet.author.account.private_visibility && current_user != @tweet.author
      raise UserGonePrivate
    end

    respond_to do |format|
      if @retweet.save
        format.turbo_stream {
          render turbo_stream: [
            turbo_stream.replace_all("#retweet_#{@tweet.id}", partial: "tweets/retweets", locals: {t: @tweet, user: current_user})
          ]
        }
        format.html { redirect_to request.referrer }
        current_user.notify(@tweet.author.id, :retweet, tweet_id: @tweet.id)
      end
    end
  rescue ActiveRecord::RecordNotUnique
    # If a user already has a retweet, it would invoke a ActiveRecord::RecordNotUnique error, so in that case, no data manipulation is to happen and a turbo request for a simple visual update is made

    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.replace_all("#retweet_#{@tweet.id}", partial: "tweets/retweets", locals: {t: @tweet, user: current_user})
        ]
      }
    end
  rescue ActiveRecord::RecordNotFound
    # ! LOOK THIS UP
    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.remove("tweet_#{retweet_params[:retweet_id]}"),
          flash.now[:alert] = "Couldn't retweet"
        ]
      }
    end
  rescue UserGonePrivate
    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.replace_all("#retweet_#{@tweet.id} .dropdown", partial: "tweets/fake_retweet_menu", locals: {t: @tweet}),
          flash.now[:alert] = "Couldn't retweet a privated tweet"
        ]
      }
    end
  end

  def destroy
    @tweet = Tweet.find(params[:id])
    if @tweet.comment?
      parent_tweet = Tweet.find(@tweet.parent_tweet_id)
      parent_tweet.update(updated_at: parent_tweet.created_at)
    end

    @tweet.destroy

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
          turbo_stream.remove("tweet_#{@tweet.id}")
        ]
      }
      format.html { redirect_to request.referrer }
      @tweet.author.notifications_received.where(notifier_id: current_user.id, notification_type: :retweet, tweet_id: @tweet.id).destroy_all
    end
  end

  def destroy_retweet
    # When user clicks undo retweet, it looks up the tweet, destroys the retweet and then broadcasts the updated count to all the users. Finally, to update the buttons correctly for the user, a format.turbo_stream request is made with the value of @og_updated By using @og_updated (meaning, the tweet after the unretweet action), it is ensured that the most updated version of the count is shown

    @og = Tweet.find(retweet_params[:retweet_id])

    @retweet = current_user.created_tweets.find_by(retweet_id: retweet_params[:retweet_id])
    @retweet.destroy

    @og_updated = @retweet.og_tweet || Tweet.find(@retweet.retweet_id)

    @og_updated.broadcast_render_later_to "retweets",
      partial: "tweets/update_retweets_count",
      locals: {t: Tweet.find(@og_updated.id)}

    respond_to do |format|
      format.html { redirect_to request.referrer }
      @tweet.author.notifications_received.where(notifier_id: current_user.id, notification_type: :retweet, tweet_id: @tweet.id).destroy_all
    end
  rescue NoMethodError
    # If a user did already unretweet (same session on 2 different tabs for example), it would invoke a NoMethodError, as @retweet would return nil and nil can't have a #destroy method executed on it, so in that case, no data manipulation is to happen and a turbo request for a simple visual update is made with the original version - @og. @og_updated couldn't be used as it is only defined after the unretweet is made

    respond_to do |format|
      @to_remove = if @retweet
        turbo_stream.remove("tweet_#{@retweet.id}")
      else
        turbo_stream.remove("tweet_#{retweet_params[:self_rt]}")
      end

      format.turbo_stream {
        render turbo_stream: [
          @to_remove,
          turbo_stream.replace_all("#retweet_#{@og.id}", partial: "tweets/retweets", locals: {t: @og, user: current_user})
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

  def retweet_params
    params.require(:retweet).permit(:retweet_id, :self_rt)
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

    # THGIS IS THE COMMENT
    og = Tweet.find(session[:og_comment_id]) if session[:og_comment_id]

    # THIS IS THE PARENT COMMENT
    Tweet.find(og.parent_tweet_id).update(updated_at: og.created_at) if og

    # Tweet.find(og.parent_tweet_id) if session[:og_comment_id]
    session.delete(:og_comment_id)
  end
end
