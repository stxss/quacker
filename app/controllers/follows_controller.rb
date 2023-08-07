class FollowsController < ApplicationController
  def create
    @user = User.find(follow_params[:followed_id])
    @follow = current_user.follow(follow_params)

    if @follow.save
      current_user.notify(follow_params[:followed_id].to_i, :follow)
      redirect_to request.referrer
    end
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Oops, something went wrong"
    redirect_to root_path
  end

  def destroy
    @follow = Follow.find(params[:id])

    if @follow.is_request && current_user == @follow.follower
      current_user.unfollow(@follow.followed)
    elsif @follow.is_request && current_user == @follow.followed
      current_user.decline_follow_request(@follow.follower)
    else
      current_user.unfollow(@follow.followed)
    end
    redirect_to request.referrer
  end

  def update
    @follow = Follow.find(params[:id])

    if @follow.is_request
      @user = @follow.follower
      current_user.accept_follow_request(@user)
    end
    redirect_to request.referrer
  end

  private

  def follow_params
    params.require(:follow).permit(:followed_id, :follower_id, :is_request)
  end
end
