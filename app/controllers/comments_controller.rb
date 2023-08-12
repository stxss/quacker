class CommentsController < TweetsController
  def create
    session[:new_comment] = 0
    @tweet = current_user.created_comments.create!(body: comment_params[:body], parent_tweet_id: params[:id])

    @og = Tweet.find(params[:id])

    @og.broadcast_render_later_to "comments",
      partial: "tweets/update_comments_count",
      locals: {t: Tweet.find(@og.id)}

    respond_to do |format|
      format.html { redirect_to root_path }
      session[:og_comment_id] = @tweet.id
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:body)
  end
end
