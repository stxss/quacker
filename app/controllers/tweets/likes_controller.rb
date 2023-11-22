class Tweets::LikesController < ApplicationController
  include ActionView::RecordIdentifier

  before_action :authenticate_user!
  before_action :set_post

  def update
    if @post.liked_by?(current_user)
      @post.unlike(current_user)
      @post.author.notifications_received.where(notifier_id: current_user.id, notification_type: :like, tweet_id: @post.id).delete_all
    else
      @post.like(current_user)
      if !@post.author.account.has_muted?(current_user)
        current_user.notify(@post.author.id, :like, tweet_id: @post.id)
      end
    end

    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: turbo_stream.replace_all("##{dom_id(@post, :likes)}", partial: "tweets/likes", locals: {t: @post})
      }
      @post.broadcast_render_later_to "likes",
        partial: "tweets/broadcast_likes",
        locals: {t: @post}
    end
  end

  private

  def set_post
    @post = Tweet.find(params[:tweet_id])
  rescue ActiveRecord::RecordNotFound
    flash.now[:alert] = "Tweet not found."
    render "tweets/_not_found", locals: {id: params[:tweet_id]}
  end
end
