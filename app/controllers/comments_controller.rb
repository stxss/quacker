class CommentsController < TweetsController
  def create
    session[:new_comment] = 0
    @comment = current_user.created_comments.create!(body: comment_params[:body], parent_tweet_id: params[:id])

    @comment.original.broadcast_render_later_to "comments",
      partial: "tweets/update_comments_count",
      locals: {t: @comment.original}

    respond_to do |format|
      format.html { redirect_to root_path }
      session[:og_comment_id] = @comment.id
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    @comment.original.update(updated_at: @comment.original.created_at)

    (current_user == @comment.author) ? @comment.destroy : raise(UnauthorizedElements)

    @comment.original.broadcast_render_later_to "comments",
      partial: "tweets/update_comments_count",
      locals: {t: @comment.original}

    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.replace_all("#tweet_#{@comment.id}.quoted ", partial: "tweets/unavailable_tweet"),
          turbo_stream.remove_all(".retweets retweets_#{@comment.id}"),
          turbo_stream.remove("tweet_#{@comment.id}")
        ]
      }
      format.html { redirect_to request.referrer }
      @comment.original.author.notifications_received.where(notifier_id: current_user.id, notification_type: :comment, tweet_id: @comment.id).delete
    end
  rescue ActiveRecord::RecordNotFound, NoMethodError
    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.remove("tweet_#{params[:id]}"),
          flash.now[:alert] = "Something went wrong, please try again!"
        ]
      }
    end
  rescue UnauthorizedElements
    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.replace_all("tweet_#{params[:id]}", partial: "tweets/single_tweet", locals: {t: @comment}),
          flash.now[:alert] = "Something went wrong, please try again!"
        ]
      }
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:body)
  end
end
