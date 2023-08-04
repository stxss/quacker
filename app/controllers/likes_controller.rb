class LikesController < ApplicationController
  def create
    # When user clicks like, it looks up the tweet, creates a like and then broadcasts the updated count to all the users. Finally, to update the buttons correctly for the user, a format.turbo_stream request is made with the value of @og instead of @tweet, because @tweet is the tweet when it wasn't yet updated with the like count, so it could induce errors. By using @og, it is ensured that the most updated version of the count is shown

    @tweet = Tweet.find(like_params[:tweet_id])

    @like = current_user.like_tweet(like_params[:tweet_id].to_i)

    @like.broadcast_render_later_to "public_likes",
      partial: "likes/update_likes_count",
      locals: {t: Tweet.find(@tweet.id)}

    @og = Tweet.find(@tweet.id)

    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.update_all(".likes #like_#{@og.id}", partial: "likes/likes", locals: {t: @og, user: current_user})
        ]
      }
      format.html { redirect_to request.referrer }
      current_user.notify(@tweet.author.id, :like, tweet_id: @tweet.id)
    end
  rescue ActiveRecord::RecordNotUnique
    # If a user already has a like, it would invoke a ActiveRecord::RecordNotUnique error, so in that case, no data manipulation is to happen and a turbo request for a simple visual update is made

    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.update_all(".likes #like_#{@tweet.id}", partial: "likes/likes", locals: {t: @tweet, user: current_user})
        ]
      }
    end
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.remove("tweet_#{like_params[:tweet_id]}"),
          flash.now[:alert] = "Couldn't like"
        ]
      }
    end
  end

  def destroy
    # When user clicks dislike, it looks up the tweet, destroys a like and then broadcasts the updated count to all the users. Finally, to update the buttons correctly for the user, a format.turbo_stream request is made with the value of @og instead of @tweet, because @tweet is the tweet when it wasn't yet updated with the like count, so it could induce errors. By using @og, it is ensured that the most updated version of the count is shown

    @tweet = Tweet.find(like_params[:tweet_id])
    @like = current_user.liked_tweets.find_by(tweet: @tweet)
    @like.destroy

    @og = @like.tweet

    @og.broadcast_render_later_to "public_likes",
      partial: "likes/update_likes_count",
      locals: {t: Tweet.find(@tweet.id)}

    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.update_all(".likes #like_#{@og.id}", partial: "likes/likes", locals: {t: @og, user: current_user})
        ]
      }
      format.html { redirect_to request.referrer }
      @tweet.author.notifications_received.where(notifier_id: current_user.id, notification_type: :like, tweet_id: @tweet.id).destroy_all
    end
  rescue NoMethodError
    # If a user did already dislike (same session on 2 different tabs for example), it would invoke a NoMethodError, as @like would return nil and nil can't have a #destroy method executed on it, so in that case, no data manipulation is to happen and a turbo request for a simple visual update is made

    # ! LOOK THIS UP
    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.update_all(".likes #like_#{@tweet.id}", partial: "likes/likes", locals: {t: @tweet, user: current_user})
        ]
      }
    end
  end

  private

  def like_params
    params.require(:like).permit(:tweet_id)
  end
end
