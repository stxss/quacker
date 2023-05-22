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
    @user = Follow.find_by(id: params[:id]).followed
    current_user.unfollow(@user)
    redirect_to username_url(@user.username)
  end

  private

  def follow_params
    params.require(:follow).permit(:followed_id)
  end
end
