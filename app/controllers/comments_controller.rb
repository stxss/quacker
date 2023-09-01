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
    @comment = Comment.with_deleted.find(params[:id])
    @original = Tweet.with_deleted.find(@comment.parent_tweet_id)
    @original&.update(comments_count: @original.comments_count - 1)

    if current_user == @comment.author
      if @comment.height > 0
        @flag = :soft_destroy
        @comment.soft_destroy
      else
        @flag = :hard_destroy
        @comment.destroy
        @original&.update_tree
        @original&.clean_up
      end
    else
      raise(UnauthorizedElements)
    end

    @original&.update(updated_at: @original.created_at)

    @original.broadcast_render_later_to "comments",
      partial: "comments/update_comments_count",
      locals: {t: @original}

    respond_to do |format|
      if @flag == :soft_destroy
        format.turbo_stream {
          render turbo_stream:
            turbo_stream.update_all("#tweet_#{@comment.id}", partial: "tweets/deleted_tweet", locals: {view: :single_post, t: Tweet.with_deleted.find(params[:id])})
        }
      elsif @flag == :hard_destroy
        format.turbo_stream
      end
      format.html { redirect_to request.referrer }
      @original.author.notifications_received.where(notifier_id: current_user.id, notification_type: :comment, tweet_id: @comment.id).delete_all
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
