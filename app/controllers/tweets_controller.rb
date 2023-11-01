class TweetsController < ApplicationController
  class UserGonePrivate < StandardError; end

  class UnauthorizedElements < StandardError; end

  # skip_before_action :set_referrer, only: [:new]

  before_action :first_visit?, :set_cache_headers, only: [:index]
  before_action :load_tweets, only: [:index, :new]
  after_action :refresh_comments, only: [:index]

  def new
    # If a request there's no request referrer, meaning it was typed into the url bar or a page refresh, basically everything that's not a click on any of the compose buttons, render the normal tweet_form and timeline
    @render_everything = request.referrer.nil?

    raise UserGonePrivate if @retweet && @retweet.author.account.private_visibility && current_user != @retweet.author
  rescue UserGonePrivate
    respond_to do |format|
      format.html { redirect_to root_path, alert: "Couldn't retweet a privated tweet" }
    end
  rescue ActiveRecord::RecordNotFound, NoMethodError
    flash.now[:alert] = "Something went wrong, please try again!"
    render "tweets/_not_found", locals: {id: (params[:original_tweet_id] || params[:parent_id])}
  end

  def index
    if session[:new_comment]&.< 2
      session[:new_comment] += 1
    elsif session[:new_comment]&.>= 2
      session.delete(:new_comment)
    end
  end

  def show
    @tweet = if Tweet.with_deleted.find(params[:id]).type.in?(["Retweet", "Quote", "Comment"])
      Tweet.with_deleted.includes({original: [author: :account]}, {comments: [{comments: {author: :account}}, {author: :account}]}, author: :account).find(params[:id])
    else
      Tweet.with_deleted.includes({comments: [{comments: {author: :account}}, {author: :account}]}, author: :account).find(params[:id])
    end
  rescue ActiveRecord::RecordNotFound
    @tweet = nil
  end

  def view_blocked_single_tweet
    @tweet = Tweet.find(params[:id])
    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: turbo_stream.replace(
          "tweet_#{params[:id]}",
          partial: "tweets/single_tweet",
          locals: {t: @tweet, view: :timeline}
        )
      }
      format.html {}
    end
  end

  def create
    @tweet = current_user.created_tweets.build(tweet_params)

    respond_to do |format|
      if @tweet.save
        format.turbo_stream
        format.html { redirect_to root_path }
      end
    end
  end

  def destroy
    @tweet = Tweet.find(params[:id])
    rts = @tweet.retweets.ids

    if current_user == @tweet.author
      (@tweet.height > 0) ? @tweet.soft_destroy : @tweet.destroy
    else
      raise(UnauthorizedElements)
    end

    respond_to do |format|
      format.turbo_stream { render "shared/destroy", locals: {tweet: @tweet, rts: rts} }
      format.html { redirect_to request.referrer }
      Notification.where(tweet_id: @tweet.id).delete_all
    end
  rescue ActiveRecord::RecordNotFound, NoMethodError
    flash.now[:alert] = "Something went wrong, please try again!"
    render "tweets/_not_found", locals: {id: params[:id]}
  rescue UnauthorizedElements
    flash.now[:alert] = "Something went wrong, please try again!"
    render "tweets/replace_tweets", locals: {id: params[:id]}
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

    @retweets ||= Retweet.where("user_id = :current_user_id OR user_id IN (#{following_ids})", current_user_id: current_user.id).includes({original: [author: :account]}, author: :account)

    @quotes ||= Quote.where("user_id = :current_user_id OR user_id IN (#{following_ids})", current_user_id: current_user.id).includes({original: [author: :account]}, {comments: [{comments: {author: :account}} , {author: :account}]}, author: :account)

    @normal ||= Tweet.where("user_id = :current_user_id OR user_id IN (#{following_ids})", current_user_id: current_user.id).where(type: nil).includes({comments: [{comments: {author: :account}} , {author: :account}]}, author: :account)

    @all_tweets = (@normal + @retweets + @quotes).sort_by(&:updated_at).reverse

    # reject muted. blocked accounts are unfollowed, so if the blocked user has commented on something that the blocker posted, it will be hidden from the timeline or a specific message shown as a disclaimer saying that the user is blocked, with a button to fetch that specific tweet in case the user wishes to see the content of the tweet, with only retweets being filtered

    # This will be used for the timeline
    @tweets = @all_tweets.reject do |tweet|
      muted_autor = current_user.account.muted_accounts.exists?(muted_id: tweet.author.id)

      author_blocked_current = tweet.type == "Retweet" && tweet.original.author.account.has_blocked?(current_user)

      has_muted_word = current_user.account.muted_words.map(&:body).any? { |muted| tweet.body.include?(muted) && tweet.author != current_user }

      muted_autor || author_blocked_current || has_muted_word
    end
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
