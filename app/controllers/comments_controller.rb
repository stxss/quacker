class CommentsController < PostsController
  # before_action :authenticate_user!

  def new
    @comment = Post.find(params[:id])
    @render_everything = request.referrer.nil?
  rescue ActiveRecord::RecordNotFound, NoMethodError
    flash.now[:alert] = "Something went wrong, please try again!"
    render partial: "posts/not_found", locals: {id: params[:id]}
  end

  def create
    session[:new_comment] = 0
    @comment = current_user.created_comments.build(body: comment_params[:body], parent_id: params[:id])
    @comment.root_id = @comment.find_root

    @comment.original.broadcast_render_later_to "comments",
      partial: "comments/update_comments_count",
      locals: {post: @comment.original}

    respond_to do |format|
      if @comment.save
        format.turbo_stream
        format.html { redirect_to root_path }

        if @comment.original && !@comment.original.author.account.has_muted?(current_user) && @comment.original.author.account.muted_words.map(&:body).none? { |muted| @comment.body.include?(muted) }
          current_user.notify(@comment.original.author.id, :comment, post_id: @comment.id)
        end
        @comment&.update_tree

        session[:og_comment_id] = @comment.id
      end
    end
  end

  def destroy
    @comment = Comment.with_deleted.find(params[:id])
    @original = Post.with_deleted.find(@comment.parent_id)
    @original&.update(comments_count: @original.comments_count - 1)

    if current_user == @comment.author
      if @comment.height > 0
        @flag = :soft_destroy
        @comment.soft_destroy
      else
        @flag = :hard_destroy
        @comment.destroy
        @original&.update_tree
      end
    else
      raise(UnauthorizedElements)
    end

    @original&.update(updated_at: @original.created_at)

    @original.broadcast_render_later_to "comments",
      partial: "comments/update_comments_count",
      locals: {post: @original}

    respond_to do |format|
      if @flag == :soft_destroy
        format.turbo_stream {
          render turbo_stream:
            turbo_stream.update_all("#post_#{@comment.id}", partial: "posts/deleted_post", locals: {view: :single_post, post: Post.with_deleted.find(params[:id])})
        }
      elsif @flag == :hard_destroy
        format.turbo_stream
        @original&.clean_up
      end
      format.html { redirect_to request.referrer }
      @original.author.notifications_received.where(notifier_id: current_user.id, notification_type: :comment, post_id: @comment.id).delete_all
    end
  rescue ActiveRecord::RecordNotFound, NoMethodError
    flash.now[:alert] = "Something went wrong, please try again!"
    render partial: "posts/not_found", locals: {id: params[:id]}
  rescue UnauthorizedElements
    flash.now[:alert] = "Something went wrong, please try again!"
    render partial: "shared/unauthorized", locals: {id: params[:id], post: @comment}
  end

  private

  def comment_params
    params.require(:comment).permit(:body)
  end
end
