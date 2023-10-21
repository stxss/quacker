class NotificationsController < ApplicationController
  def index
    @notifications = current_user.notifications_received.all.ordered.reject { |notification| notification.notifier.account.has_blocked?(current_user) || current_user.account.has_blocked?(notification.notifier) }
  end
end
