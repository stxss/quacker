class Posts::LikesController < ApplicationController
  include ActionView::RecordIdentifier

  before_action :authenticate_user!
  before_action :set_post

  def update
    if @post.liked_by?(current_user)
      @post.unlike(current_user)
      @post.author.notifications_received.where(notifier_id: current_user.id, notification_type: :like, post_id: @post.id).delete_all
    else
      @post.like(current_user)
      unless @post.author.account.has_muted?(current_user)
        current_user.notify(@post.author.id, :like, post_id: @post.id)
      end
    end

    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: turbo_stream.replace_all("##{dom_id(@post, :likes)}", partial: "posts/likes", locals: {post: @post})
      }
      @post.broadcast_render_later_to "likes",
        partial: "posts/broadcast_likes",
        locals: {post: @post}
    end
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  rescue ActiveRecord::RecordNotFound
    flash.now[:alert] = "Post not found."
    render partial: "posts/not_found", locals: {id: params[:post_id]}
  end
end
