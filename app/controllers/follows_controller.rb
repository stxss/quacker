class FollowsController < ApplicationController
  # before_action :logged_in_user

  def create
    @user = User.find_by(id: params[:followed_id])
    current_user.follow(@user)
    redirect_to username_url(@user.username)
  end

  def destroy
    @user = Follow.find_by(id: params[:id]).followed
    current_user.unfollow(@user)
    redirect_to username_url(@user.username)
  end
end
