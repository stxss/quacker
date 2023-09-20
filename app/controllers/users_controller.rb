class UsersController < ApplicationController
  def show
    @show_replies = true
    @user = User.find_by(username: params[:username])
    @normal = @user.created_tweets.includes(author: :account).where(type: nil)
    @quotes = @user.created_quotes.includes(original: [author: :account], author: :account)
    @retweets = @user.created_retweets.includes(original: [author: :account], author: :account)
    @tweets = (@normal + @quotes + @retweets - @user.created_comments).sort_by(&:updated_at)&.reverse
  end

  def show_replies
    @user = User.find_by(username: params[:username])

    @query = @user.created_comments.includes(original: [author: :account], author: :account).sort_by(&:updated_at)&.reverse

    @replies = @query.each do |comment|
      @query.delete(comment.original) if comment.original.in?(@query)
    end
  end

  def index_liked_tweets
    @user = User.find_by(username: params[:username])
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
end
