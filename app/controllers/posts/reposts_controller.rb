class Posts::RepostsController < PostsController
  include ActionView::RecordIdentifier

  before_action :authenticate_user!
  before_action :set_post

  # def create
  #   # When user clicks repost, it looks up the post, creates a repost and then broadcasts the updated count to all the users. Finally, to update the buttons correctly for the user, a format.turbo_stream request is made with the value of the post as the original has been updated with a repost count. By fetching the original post after the update, the most recent values are assured and errors minimized
  #
  #   @repost = current_user.created_reposts.build(repost_original_id: params[:repost_original_id])
  #   @repost.original.broadcast_render_later_to "reposts",
  #     partial: "reposts/update_reposts_count",
  #     locals: {t: @repost.original}
  #
  #   raise UserGonePrivate if @repost.original.author.account.private_visibility && current_user != @repost.original.author
  #
  #   respond_to do |format|
  #     if @repost.save
  #       format.turbo_stream { render partial: "reposts/replace_reposts", locals: {t: @repost, user: current_user} }
  #       format.html { redirect_to request.referrer }
  #       unless @repost.original.author.account.has_muted?(current_user)
  #         current_user.notify(@repost.original.author.id, :repost, post_id: @repost.original.id)
  #       end
  #     end
  #   end
  # rescue ActiveRecord::RecordNotUnique
  #   # If a user already has a repost, it would invoke a ActiveRecord::RecordNotUnique error, so in that case, no data manipulation is to happen and a turbo request for a simple visual update is made
  #
  #   flash.now[:alert] = "Can't repost twice"
  #   render "reposts/replace_reposts", locals: {t: @repost, user: current_user}
  # rescue ActiveRecord::RecordNotFound
  #   flash.now[:alert] = "Couldn't repost a deleted post."
  #   render "posts/_not_found", locals: {id: repost_params[:repost_original_id]}
  # rescue UserGonePrivate
  #   flash.now[:alert] = "Couldn't repost a protected post"
  #   render "reposts/private_repost_menu", locals: {t: @repost}
  # end
  #
  # def destroy
  #   # When user clicks undo repost, it looks up the post, destroys the repost and then broadcasts the updated count to all the users. Finally, to update the buttons correctly for the user, a format.turbo_stream request is made with the value of @repost.original By using @repost.original (meaning, the post after the undo repost action), it is ensured that the most updated version of the count is shown
  #
  #   # will raise ActiveRecord::RecordNotFound if the post is deleted
  #   @original = Post.find(repost_params[:repost_original_id])
  #
  #   # will raise NoMethodError if the user did already undo repost
  #   @repost = current_user.created_reposts.find_by(repost_original_id: repost_params[:repost_original_id])
  #
  #   raise NoMethodError if @repost.nil?
  #
  #   @repost.destroy
  #
  #   # @repost.original is the updated version of the post
  #   @repost.original.broadcast_render_later_to "reposts",
  #     partial: "reposts/update_reposts_count",
  #     locals: {t: @repost.original}
  #
  #   respond_to do |format|
  #     format.turbo_stream
  #     format.html { redirect_to request.referrer }
  #     @repost.original.author.notifications_received.where(notifier_id: current_user.id, notification_type: :repost, post_id: @repost.original.id).delete_all
  #   end
  # rescue NoMethodError
  #   # If a user did already unrepost (same session on 2 different tabs for example), it would invoke a NoMethodError, as @repost would return nil and nil can't have a #destroy method executed on it, so in that case, no data manipulation is to happen and a turbo request for a simple visual update is made with the original version - @original. @repost.original couldn't be used as it is only defined after the unrepost is made
  #
  #   flash.now[:alert] = "Can't unrepost twice"
  #   render "reposts/destroy", locals: {repost_id: repost_params[:self_rt], user: current_user}
  # rescue ActiveRecord::RecordNotFound
  #   flash.now[:alert] = "Couldn't unrepost a deleted post."
  #   render "reposts/_not_found", locals: {original_post_id: repost_params[:repost_original_id], repost_id: repost_params[:self_rt]}
  # end

  def update
    if @post.reposted_by?(current_user)
      @post.unrepost(current_user)
      @post.author.notifications_received.where(notifier_id: current_user.id, notification_type: :like, post_id: @post.id).delete_all
    else
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
    render "posts/_not_found", locals: {id: params[:post_id]}
  end
end
