class UsersController < ApplicationController
  before_action :check_blocks, only: [:show, :show_replies, :index_liked_posts]

  def show
    @show_replies = true
    fetch_posts(params[:username]) unless @blocking || @blocked

    respond_to do |format|
      format.html {
        render template: "users/show", locals: {user: @user, posts: @posts, blocked: @blocked, blocking: @blocking}
      }
    end
  end

  def view_blocked_posts
    fetch_posts(params[:username])

    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: turbo_stream.replace(
          "all-posts-#{@user.id}",
          partial: "users/all_posts",
          locals: {user: @user, posts: @posts}
        )
      }
      format.html {}
    end
  end

  def view_blocked_likes
    @user = User.find_by(username: params[:username])
    @likes = @user.all_likes(current_user, bypass: true)

    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: turbo_stream.replace(
          "all-posts-#{@user.id}",
          partial: "users/all_likes",
          locals: {user: @user, likes: @likes}
        )
      }
      format.html {}
    end
  end

  def view_blocked_replies
    @user = User.find_by(username: params[:username])
    @replies = @user.all_replies

    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: turbo_stream.replace(
          "all-posts-#{@user.id}",
          partial: "users/all_replies",
          locals: {user: @user, replies: @replies}
        )
      }
      format.html {}
    end
  end

  def show_replies
    @user = User.find_by(username: params[:username])
    @replies = @user.all_replies unless @blocking || @blocked

    respond_to do |format|
      format.html {
        render template: "users/show_replies", locals: {user: @user, replies: @replies, blocking: @blocking, blocked: @blocked}
      }
    end
  end

  def index_liked_posts
    @user = User.find_by(username: params[:username])

    redirect_to username_url(@user.username) if @user.account.private_likes? && @user != current_user

    # Reject likes where the author has blocked the current user, or the current user has blocked the author, or the current user is not following the author and the author is private
    @likes = @user.all_likes(current_user) unless @blocking || @blocked

    respond_to do |format|
      format.html {
        render template: "users/index_liked_posts", locals: {user: @user, likes: @likes, blocked: @blocked, blocking: @blocking}
      }
    end
  end

  def edit
    @user = current_user
    session[:current_user_username] = current_user.username

    following_ids = "SELECT followed_id FROM follows WHERE follower_id = :current_user_id"
    @posts = Post.where("user_id = :current_user_id OR user_id IN (#{following_ids})", current_user_id: current_user.id)

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

  def fetch_posts(username)
    @user = User.find_by(username: username)
    @posts = @user.all_posts(current_user)
  end

  def check_blocks
    @user = User.find_by(username: params[:username])
    @blocking = current_user.account.has_blocked?(@user)
    @blocked = @user.account.has_blocked?(current_user)
  end
end
