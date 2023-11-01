class QuotesController < TweetsController
  # before_action :authenticate_user!

  def new
    @retweet = Tweet.find(params[:id])
    @render_everything = request.referrer.nil?

    raise UserGonePrivate if @retweet && @retweet.author.account.private_visibility && current_user != @retweet.author
  rescue UserGonePrivate
    respond_to do |format|
      format.html { redirect_to root_path, alert: "Couldn't retweet a privated tweet" }
    end
  rescue ActiveRecord::RecordNotFound, NoMethodError
    flash.now[:alert] = "Something went wrong, please try again!"
    render "tweets/_not_found", locals: {id: params[:id]}
  end

  def create
    @quote = current_user.created_quotes.build(body: quote_params[:body], quoted_tweet_id: params[:id])

    @quote.original&.broadcast_render_later_to "retweets",
      partial: "retweets/update_retweets_count",
      locals: {t: @quote.original}

    raise UserGonePrivate if @quote.original.author.account.private_visibility && current_user != @quote.original.author

    respond_to do |format|
      if @quote.save
        format.turbo_stream
        format.html { redirect_to root_path }
        if @quote.original && !@quote.original.author.account.has_muted?(current_user) && @quote.original.author.account.muted_words.map(&:body).none? { |muted| @quote.body.include?(muted) }
          current_user.notify(@quote.original.author.id, :quote, tweet_id: @quote.id)
        end
      end
    end
  rescue UserGonePrivate
    flash[:alert] = "Can't quote a protected tweet unless you're the author"
    render json: {}, status: :forbidden
  rescue ActiveRecord::RecordNotFound, NoMethodError
    flash.now[:alert] = "Something went wrong, please try again!"
    render "tweets/_not_found", locals: {id: params[:id]}
  end

  def destroy
    @quote = Quote.find(params[:id])
    rts = @quote.retweets.ids

    if current_user == @quote.author
      (@quote.height > 0) ? @quote.soft_destroy : @quote.destroy
    else
      raise(UnauthorizedElements)
    end

    @quote.original&.broadcast_render_later_to "retweets",
      partial: "retweets/update_retweets_count",
      locals: {t: @quote.original}

    respond_to do |format|
      format.turbo_stream { render "shared/destroy", locals: {tweet: @quote, rts: rts} }
      format.html { redirect_to request.referrer }
      @quote.original.author.notifications_received.where(notifier_id: current_user.id, notification_type: :quote, tweet_id: @quote.id).delete_all if @quote.original
    end
  rescue ActiveRecord::RecordNotFound, NoMethodError
    flash.now[:alert] = "Something went wrong, please try again!"
    render "tweets/_not_found", locals: {id: params[:id]}
  rescue UnauthorizedElements
    flash.now[:alert] = "Something went wrong, please try again!"
    render "shared/_unauthorized", locals: {id: params[:id], t: @quote}
  end

  private

  def quote_params
    params.require(:quote).permit(:body)
  end
end
