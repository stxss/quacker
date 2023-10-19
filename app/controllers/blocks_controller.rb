class BlocksController < ApplicationController
  def index
    @blocked_accounts = current_user.account.blocked_accounts.all
  end

  def create
    @user = User.find(block_params[:blocked_id])

    # As a block is a two-way relationship, we need to block the users from both sides to each other, meaning that we need to unfollow them and hide any notifications, likes, messages and anything that they had in common, apart from retweets or quote tweets, which will just display a message to the blocking user saying "you've blocked the user (...)" and to the blocked user saying "you can't see this tweet because you've been blocked (...)"

    current_user.unfollow(@user) if current_user.following?(@user)
    @user.unfollow(current_user) if @user.following?(current_user)

    @blocked_account = current_user.account.block(block_params)

    respond_to do |format|
      format.turbo_stream { flash.now[:notice] = "@#{@user.username} has been blocked. Refresh to see changes" }
    end
  end

  def destroy
    @user = User.find(params[:id])
    @blocked_account = current_user.account.blocked_accounts.find_by(blocked_id: @user.id).delete
    respond_to do |format|
      format.turbo_stream { flash.now[:notice] = " @#{@user.username} has been unblocked. Refresh to see changes" }
    end
  end

  private

  def block_params
    params.require(:block).permit(:blocked_id)
  end
end
