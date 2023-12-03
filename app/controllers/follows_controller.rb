class FollowsController < ApplicationController
  def create
    @user = User.find(follow_params[:followed_id])
    @follow = current_user.follow(follow_params)

    respond_to do |format|
      if @follow.save
        format.turbo_stream
        format.html {}
      end
      unless @user.account.has_muted?(current_user)
        current_user.notify(@user.id, :follow)
      end
    end
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Oops, something went wrong"
    redirect_to root_path
  end

  def destroy
    @follow = Follow.find(params[:id])

    respond_to do |format|
      if @follow.is_request && current_user == @follow.follower
        current_user.unfollow(@follow.followed)
        format.html { redirect_to request.referrer }
      elsif @follow.is_request && current_user == @follow.followed
        @user = @follow.follower
        current_user.decline_follow_request(@follow.follower)
        if current_user.passive_follows.size >= 1
          format.turbo_stream { render turbo_stream: turbo_stream.remove(@follow.id) }
        else
          format.turbo_stream {
            render turbo_stream: turbo_stream.replace(@follow.id, "<h3>You’re up to date</h3>
          <span>When someone requests to follow you, it’ll show up here for you to accept or decline.</span>")}
        end
      else
        @user = @follow.followed
        current_user.unfollow(@user)
        (@user.account.private_visibility == true) ? format.html { redirect_to request.referrer } : format.turbo_stream
      end
    end
  end

  def update
    @follow = Follow.find(params[:id])
    if @follow.is_request
      current_user.accept_follow_request(@follow.follower)
    end
    redirect_to request.referrer
  end

  private

  def follow_params
    params.require(:follow).permit(:followed_id, :follower_id, :is_request)
  end
end
