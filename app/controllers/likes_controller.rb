class LikesController < ApplicationController
  def create
    @like = current_user.like_tweet(like_params)
    @tweet = Tweet.find(like_params[:tweet_id])

    respond_to do |format|
      if @like.save
        format.turbo_stream {
          render turbo_stream: [
            turbo_stream.update("like_count_#{@tweet.id}", partial: "tweets/like_count", locals: {tweet: @tweet}),
            turbo_stream.update("like_#{@tweet.id}", partial: "tweets/unlike_button", locals: { tweet: @tweet})
          ]
        }
          format.html { redirect_to request.referrer }
      else
        flash.now[:alert] = "Oops, something went wrong, check your fields again"
        render :edit, status: :unprocessable_entity
      end
    end
  end

  def destroy
    # @like = Like.find(params[:id])
    @tweet = Tweet.find(like_params[:tweet_id])
    @like = current_user.liked_tweets.find_by(tweet: @tweet)

    respond_to do |format|
      if @like.destroy
        format.turbo_stream {
          render turbo_stream: [
            turbo_stream.update("like_count_#{@tweet.id}", partial: "tweets/like_count", locals: {tweet: @tweet}),
            turbo_stream.update("like_#{@tweet.id}", partial: "tweets/like_button", locals: {tweet: @tweet})
          ]
        }
        format.html { redirect_to request.referrer }
      else
        flash.now[:alert] = "Oops, something went wrong, check your fields again"
        render :edit, status: :unprocessable_entity
      end
    end
  end

  private

  def like_params
    params.require(:like).permit(:tweet_id)
  end
end
