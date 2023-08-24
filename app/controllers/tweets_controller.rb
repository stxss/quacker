class TweetsController < ApplicationController
  class UserGonePrivate < StandardError; end
  class UnauthorizedElements < StandardError; end

  # skip_before_action :set_referrer, only: [:new]

  before_action :first_visit?, :set_cache_headers, only: [:index]
  before_action :load_tweets, only: [:index, :new]
  after_action :refresh_comments, only: [:index]

  def new
    if params[:original_tweet_id].present?
      @retweet = Tweet.find(params[:original_tweet_id])
    elsif params[:parent_tweet_id].present?
      @comment = Tweet.find(params[:parent_tweet_id])
    end

    # If a request if a GET, meaning it was typed into the url bar or a page refresh, basically everything that's not a click on any of the compose buttons, render the normal tweet_form and timeline
    @render_everything = request.method == "GET"

    raise UserGonePrivate if @retweet && @retweet.author.account.private_visibility && current_user != @retweet.author
  rescue UserGonePrivate
    respond_to do |format|
      format.html { redirect_to root_path, alert: "Couldn't retweet a privated tweet" }
    end
  end

  def index
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
    @tweet = current_user.created_tweets.create!(tweet_params)

    respond_to do |format|
      format.html { redirect_to root_path }
    end
  end

  def destroy
    @tweet = Tweet.find(params[:id])

    (current_user == @tweet.author) ? @tweet.destroy : raise(UnauthorizedElements)

    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.replace_all("#tweet_#{@tweet.id}.quoted ", partial: "tweets/unavailable_tweet"),
          turbo_stream.remove_all(".retweets retweets_#{@tweet.id}"),
          turbo_stream.remove("tweet_#{@tweet.id}")
        ]
      }
      format.html { redirect_to request.referrer }
      Notification.where(tweet_id: @tweet.id).delete_all
    end
  rescue ActiveRecord::RecordNotFound, NoMethodError
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

  private

  def tweet_params
    params.require(:tweet).permit(:body)
  end

  def first_visit?
    session[:first_visit] = current_user.sign_in_count == 1 && session[:first_visit].nil?
  end

  def load_tweets
    following_ids = "SELECT followed_id FROM follows WHERE follower_id = :current_user_id AND is_request = false"
    @tweets ||= Tweet.where("user_id = :current_user_id OR user_id IN (#{following_ids})", current_user_id: current_user.id).where(type: ["Retweet", "Quote", nil]).includes(:comments, :quote_tweets, :retweets, :likes, :author).ordered.load
  end

  def set_cache_headers
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

  def refresh_comments
    return if !session[:new_comment]

    # THIS IS THE COMMENT
    comment = Comment.find_by(id: session[:og_comment_id])

    # THIS IS THE PARENT COMMENT
    comment&.original&.update(updated_at: comment.created_at)

    session.delete(:og_comment_id)
  end
end
