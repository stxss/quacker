class MutedAccountsController < ApplicationController
  def index
    @muted_accounts = current_user.account.muted_accounts
  end

  def create
    @user = User.find(mute_params[:muted_id])
    @muted_account = current_user.account.mute(mute_params)

    respond_to do |format|
      format.turbo_stream { flash.now[:notice] = "@#{@user.username} has been muted. Refresh to see changes" }
    end
  end

  def destroy
    @user = User.find(params[:id])
    @muted_account = current_user.account.muted_accounts.find_by(muted_id: @user.id).delete
    respond_to do |format|
      format.turbo_stream { flash.now[:notice] = "@#{@user.username} has been unmuted. Refresh to see changes" }
    end
  end

  private

  def mute_params
    params.require(:muted_account).permit(:muted_id)
  end
end
