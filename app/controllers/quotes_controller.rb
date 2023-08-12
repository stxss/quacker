class QuotesController < TweetsController
  def create
    @tweet = current_user.created_quotes.create!(body: quote_params[:body], quoted_retweet_id: params[:id])

    @og = Tweet.find(params[:id])

    @og.broadcast_render_later_to "retweets",
      partial: "tweets/update_retweets_count",
      locals: {t: Tweet.find(@og.id)}

    respond_to do |format|
      format.html { redirect_to root_path }
    end
  end

  private

  def quote_params
    params.require(:quote).permit(:body)
  end
end
