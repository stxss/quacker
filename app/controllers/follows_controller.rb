class FollowsController < ApplicationController
  def create
    @user = User.find(follow_params[:followed_id])
    @follow = current_user.follow(follow_params)

    respond_to do |format|
      if @follow.save
        format.turbo_stream
        format.html {}
      end
      current_user.notify(@user.id, :follow)
    end
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Oops, something went wrong"
    redirect_to root_path
  end

  def destroy
    @follow = Follow.find(params[:id])

    if @follow.is_request && current_user == @follow.follower
      current_user.unfollow(@follow.followed)
      redirect_to request.referrer
    elsif @follow.is_request && current_user == @follow.followed
      current_user.decline_follow_request(@follow.follower)
    else
      @user = @follow.followed
      current_user.unfollow(@user)
      respond_to do |format|
        format.turbo_stream
        format.html {}
      end
    end
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
