class FollowsController < ApplicationController
  # before_action :logged_in_user

  def create
    @user = User.find_by(id: follow_params[:followed_id])

    @follow = current_user.follow(follow_params)

    if @follow.save
      current_user.notify(follow_params[:followed_id].to_i, :follow)
      redirect_to username_url(@user.username)
    else
      flash[:alert] = "Oops, something went wrong"
      redirect_to root_path
    end
  end

  def destroy
    @follow = Follow.find(params[:id])

    if @follow.is_request
      @user = @follow.follower
      current_user.decline_follow_request(@user)
      redirect_to request.referrer
    else
      @user = @follow.followed
      current_user.unfollow(@user)
      redirect_to username_url(@user.username)
    end
  end

  def update
    @follow = Follow.find(params[:id])

    if @follow.is_request
      @user = @follow.follower
      current_user.accept_follow_request(@user)
    else
      flash[:alert] = "Oops, something went wrong"
      redirect_to root_path
    end
    redirect_to request.referrer
  end

  private

  def follow_params
    params.require(:follow).permit(:followed_id, :follower_id, :is_request)
  end
end
