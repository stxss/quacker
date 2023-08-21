class QuotesController < TweetsController
  # before_action :authenticate_user!
  def new
    @original_tweet = Tweet.find(params[:original_tweet_id])

    raise UserGonePrivate if @original_tweet && @original_tweet.author.account.private_visibility && current_user != @original_tweet.author
  rescue UserGonePrivate
    flash[:alert] = "Can't quote a protected tweet unless you're the author"
    render json: {}, status: :forbidden
  end

  def create
    @quote = current_user.created_quotes.build(body: quote_params[:body], quoted_retweet_id: params[:id])

    @quote.original.broadcast_render_later_to "retweets",
      partial: "retweets/update_retweets_count",
      locals: {t: @quote.original}

    raise UserGonePrivate if @quote.original.author.account.private_visibility && current_user != @quote.original.author

    respond_to do |format|
      if @quote.save
        format.html { redirect_to root_path }
      end
    end
  rescue UserGonePrivate
    respond_to do |format|
      format.html { redirect_to root_path, alert: "Couldn't retweet a privated tweet" }
    end
  end

  def destroy
    @quote = Quote.find(params[:id])

    (current_user == @quote.author) ? @quote.destroy : raise(UnauthorizedElements)

    @quote.original.broadcast_render_later_to "retweets",
      partial: "retweets/update_retweets_count",
      locals: {t: @quote.original}

    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.replace_all("#tweet_#{@quote.id}.quoted ", partial: "tweets/unavailable_tweet"),
          turbo_stream.remove_all(".retweets retweets_#{@quote.id}"),
          turbo_stream.remove("tweet_#{@quote.id}")
        ]
      }
      format.html { redirect_to request.referrer }
      @quote.original.author.notifications_received.where(notifier_id: current_user.id, notification_type: :quote, tweet_id: @quote.id).delete_all
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
          turbo_stream.replace_all("tweet_#{params[:id]}", partial: "tweets/single_tweet", locals: {t: @quote}),
          flash.now[:alert] = "Something went wrong, please try again!"
        ]
      }
    end
  end

  private

  def quote_params
    params.require(:quote).permit(:body)
  end
end
