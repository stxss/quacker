class Posts::RepostsController < PostsController
  include ActionView::RecordIdentifier

  before_action :authenticate_user!
  before_action :set_post

  def update
    if @post.reposted_by?(current_user)
      @post.unrepost(current_user)
      @post.author.notifications_received.where(notifier_id: current_user.id, notification_type: :like, post_id: @post.id).delete_all
    else
      raise UserGonePrivate if @post.author.account.private_visibility && current_user != @post.author

      @post.repost(current_user)
      unless @post.author.account.has_muted?(current_user)
        current_user.notify(@post.author.id, :like, post_id: @post.id)
      end
    end

    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: turbo_stream.replace_all("##{dom_id(@post, :reposts)}", partial: "posts/reposts", locals: {post: @post})
      }
      @post.broadcast_render_later_to "reposts",
        partial: "posts/broadcast_reposts",
        locals: {post: @post}
    end
  rescue UserGonePrivate
    flash.now[:alert] = "Couldn't repost a protected post"
    render partial: "reposts/private_repost_menu", locals: {post: @post}
  end

  private

  def repost_params
    params.require(:repost).permit(:repost_original_id, :self_rt)
  rescue ActionController::ParameterMissing
    {}
  end

  def set_post
    @post = Post.find(params[:post_id])
  rescue ActiveRecord::RecordNotFound
    flash.now[:alert] = "Post not found."
    render partial: "posts/not_found", locals: {id: params[:post_id]}
  end
end
