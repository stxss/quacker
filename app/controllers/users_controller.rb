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
          "all-tweets-#{@user.id}",
          partial: "users/all_tweets",
          locals: {user: @user, tweets: @tweets}
        )
      }
      format.html {}
    end
  end

  def view_blocked_likes
    @user = User.find_by(username: params[:username])
    @likes = @user.all_likes(current_user)

    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: turbo_stream.replace(
          "all-tweets-#{@user.id}",
          partial: "users/all_likes",
          locals: {user: @user, likes: @likes}
        )
      }
      format.html {}
    end
  end

  def view_blocked_replies
    @user = User.find_by(username: params[:username])
    @replies = @user.all_replies(current_user)

    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: turbo_stream.replace(
          "all-tweets-#{@user.id}",
          partial: "users/all_replies",
          locals: {user: @user, replies: @replies}
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

    redirect_to username_url(@user.username) if @user.account.private_likes? && @user != current_user

    # Reject likes where the author has blocked the current user, or the current user has blocked the author, or the current user is not following the author and the author is private
    @likes = @user.all_likes(current_user) if !(@blocking || @blocked)
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
    @tweets = @user.all_tweets(current_user)
  end

  def check_blocks
    @user = User.find_by(username: params[:username])
    @blocking = current_user.account.has_blocked?(@user)
    @blocked = @user.account.has_blocked?(current_user)
  end
end
