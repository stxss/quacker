class AccountsController < ApplicationController
  def update
    @account = current_user.account

    if @account.update(account_params)
      redirect_to request.referrer
    else
      flash.now[:alert] = "Oops, something went wrong, check your fields again"
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def account_params
    params.require(:account).permit(:private_visibility, :private_likes, :allow_media_tagging, :sensitive_media, :display_sensitive_media, :hide_potentially_sensitive_content, :remove_blocked_and_muted_accounts, :muted_notif_you_dont_follow, :muted_notif_dont_follow_you, :muted_notif_new_account, :muted_notif_default_profile_pic, :muted_notif_no_confirm_email, :allow_message_request_from_everyone, :show_read_receipts)
  end
end

# https://stackoverflow.com/questions/48280713/rails-5-multiple-edit-views-for-one-update-controller-action

# https://rails-bestpractices.com/posts/2010/07/24/dry-metaprogramming/
