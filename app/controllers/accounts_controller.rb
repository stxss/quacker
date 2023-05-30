class AccountsController < ApplicationController
  SETTINGS_METHODS = %w[privacy_and_safety
    audience_and_tagging
    tagging
    your_tweets
    content_you_see
    search
    mute_and_block
    blocked_all
    blocked_imported
    muted_all
    muted_keywords
    notifications_advanced_filters
    direct_messages
  ]

  class << self
    SETTINGS_METHODS.each do |setting_name|
      define_method "edit_#{setting_name}" do
        @account = current_user.account
      end
    end
  end

  def edit
    @account = current_user.account
  end

  def update
    @account = current_user.account

    if @account.update(account_params)
      # redirect_to username_url(current_user.username)
      redirect_to request.referrer
    else
      flash.now[:alert] = "Oops, something went wrong, check your fields again"
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def account_params
    params.require(:account).permit(:private_visibility, :allow_media_tagging, :sensitive_media, :display_sensitive_media, :hide_potentially_sensitive_content, :remove_blocked_and_muted_accounts, :muted_notif_you_dont_follow, :muted_notif_dont_follow_you, :muted_notif_new_account, :muted_notif_default_profile_pic, :muted_notif_no_confirm_email, :allow_message_request_from_everyone, :show_read_receipts)
  end
end

# https://stackoverflow.com/questions/48280713/rails-5-multiple-edit-views-for-one-update-controller-action

# https://rails-bestpractices.com/posts/2010/07/24/dry-metaprogramming/
