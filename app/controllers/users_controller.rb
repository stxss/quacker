class UsersController < ApplicationController

  before_action :check_blocks, only: [:show, :show_replies, :index_liked_tweets]

  def show
    @show_replies = true
    fetch_tweets(params[:username]) if !(@blocking || @blocked)
  end

  def view_blocked_posts
    fetch_tweets(params[:username])

    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: turbo_stream.replace(
          "all_tweets",
          partial: "users/all_tweets"
        )
      }
      format.html {}
    end
  end

  def view_blocked_likes
    @user = User.find_by(username: params[:username])
    @likes = @user.liked_tweets.order(created_at: :desc)

    @likes = @user.liked_tweets.includes(tweet: {author: :account}).order(created_at: :desc).reject { |like|
      (like.tweet.author != @user && (like.tweet.author.account.has_blocked?(current_user) || current_user.account.has_blocked?(like.tweet.author))) ||
        (!current_user.following?(like.tweet.author) &&
        like.tweet.author.account.private_visibility)
    }

    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: turbo_stream.replace(
          "all_tweets",
          partial: "users/all_likes"
        )
      }
      format.html {}
    end
  end

  def view_blocked_replies
    @user = User.find_by(username: params[:username])
    @query = @user.created_comments.includes(original: [author: :account], author: :account).sort_by(&:updated_at)&.reverse

    @replies = @query.each do |comment|
      @query.delete(comment.original) if comment.original.in?(@query)
    end

    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: turbo_stream.replace(
          "all_tweets",
          partial: "users/all_replies"
        )
      }
      format.html {}
    end
  end

  def show_replies
    @user = User.find_by(username: params[:username])
    if !(@blocking || @blocked)
      @query = @user.created_comments.includes(:root, :original, author: :account).sort_by(&:updated_at)&.reverse

      @replies = @query.each do |comment|
        @query.delete(comment.original) if comment.original.in?(@query)
      end
    end
  end

  def index_liked_tweets
    @user = User.find_by(username: params[:username])

    # Reject likes where the author has blocked the current user, or the current user has blocked the author, or the current user is not following the author and the author is private
    if !(@blocking || @blocked)
      @likes = User.find_by(username: params[:username]).liked_tweets.includes(tweet: {author: :account}).order(created_at: :desc).reject { |like| like.tweet.author.account.has_blocked?(current_user) || current_user.account.has_blocked?(like.tweet.author) || (!current_user.following?(like.tweet.author) && like.tweet.author.account.private_visibility) }
    end
  end

  def edit
    @user = current_user
    session[:current_user_username] = current_user.username

    following_ids = "SELECT followed_id FROM follows WHERE follower_id = :current_user_id"
    @tweets = Tweet.where("user_id = :current_user_id OR user_id IN (#{following_ids})", current_user_id: current_user.id)

    if !request.referrer || request.referrer.split("/").last != current_user.username
      session[:edit_profile] = true
    end
  end

  def update
    @user = current_user

    respond_to do |format|
      if @user.update(user_params)
        format.turbo_stream
        format.html { redirect_to username_url(current_user.username) }
      else
        flash.now[:alert] = "Oops, something went wrong, check your fields again"
        render :edit, status: :unprocessable_entity
      end
    end
  end

  private

  def user_params
    params.require(:user).permit(:display_name, :biography, :location, :website, :birth_date)
  end

  def fetch_tweets(username)
    @user = User.find_by(username: username)
    @normal = @user.created_tweets.includes(author: :account).where(type: nil)
    @quotes = @user.created_quotes.includes(original: [author: :account], author: :account)
    @retweets = @user.created_retweets.includes(original: [author: :account], author: :account)

    @tweets = (@normal + @quotes + @retweets - @user.created_comments).reject { |tweet| (tweet.type == "Retweet" && tweet.original.author.account.has_blocked?(current_user)) }.sort_by(&:updated_at)&.reverse
  end

  def check_blocks
    @user = User.find_by(username: params[:username])
    @blocking = current_user.account.has_blocked?(@user)
    @blocked = @user.account.has_blocked?(current_user)
  end
end
