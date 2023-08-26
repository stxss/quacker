class CommentsController < TweetsController
  def create
    session[:new_comment] = 0
    @comment = current_user.created_comments.build(body: comment_params[:body], parent_tweet_id: params[:id])
    @comment.root_id = @comment.find_root

    @comment.original.broadcast_render_later_to "comments",
      partial: "comments/update_comments_count",
      locals: {t: @comment.original}

    respond_to do |format|
      if @comment.save
        format.turbo_stream
        format.html { redirect_to root_path }
        current_user.notify(@comment.original.author.id, :comment, tweet_id: @comment.id)
        @comment&.update_tree

        session[:og_comment_id] = @comment.id
      end
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    @comment.original.update(updated_at: @comment.original.created_at)

    # (current_user == @comment.author) ? @comment.destroy : raise(UnauthorizedElements)

    if current_user == @comment.author
      (@comment.height > 0) ? @comment.soft_destroy : @comment.destroy
    else
      raise(UnauthorizedElements)
    end

    @comment.original&.update_tree

    @comment.original.broadcast_render_later_to "comments",
      partial: "comments/update_comments_count",
      locals: {t: @comment.original}

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to request.referrer }
      @comment.original.author.notifications_received.where(notifier_id: current_user.id, notification_type: :comment, tweet_id: @comment.id).delete_all
    end
  rescue ActiveRecord::RecordNotFound, NoMethodError
    flash.now[:alert] = "Something went wrong, please try again!"
    render "tweets/_not_found", locals: {id: params[:id]}
  rescue UnauthorizedElements
    flash.now[:alert] = "Something went wrong, please try again!"
    render "shared/_unauthorized", locals: {id: params[:id], t: @comment}
  end

  private

  def comment_params
    params.require(:comment).permit(:body)
  end
end
