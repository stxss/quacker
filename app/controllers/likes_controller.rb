class LikesController < ApplicationController
  def create
    # When user clicks like, it looks up the tweet, creates a like and then broadcasts the updated count to all the users. Finally, to update the buttons correctly for the user, a format.turbo_stream request is made with the value of @og instead of @tweet, because @tweet is the tweet when it wasn't yet updated with the like count, so it could induce errors. By using @og, it is ensured that the most updated version of the count is shown

    @tweet = Tweet.find(like_params[:tweet_id])

    @like = current_user.liked_tweets.build(tweet_id: @tweet.id)

    @like.tweet.broadcast_update_later_to "likes",
      target: "like_count_#{@like.tweet.id}",
      partial: "likes/update_likes_count",
      locals: {t: @like.tweet}

    respond_to do |format|
      if @like.save
        format.turbo_stream { render "likes/replace_likes", locals: {t: @like.tweet, user: current_user} }
        format.html { redirect_to request.referrer }
      end
      if !@tweet.author.account.has_muted?(current_user)
        current_user.notify(@tweet.author.id, :like, tweet_id: @tweet.id)
      end
    end
  rescue ActiveRecord::RecordNotUnique
    # If a user already has a like, it would invoke a ActiveRecord::RecordNotUnique error, so in that case, no data manipulation is to happen and a turbo request for a simple visual update is made
    flash.now[:alert] = "Can't like it twice."
    render "likes/replace_likes", locals: {t: @tweet, user: current_user}
  rescue ActiveRecord::RecordNotFound
    flash.now[:alert] = "Couldn't like a deleted tweet."
    render "tweets/_not_found", locals: {id: like_params[:tweet_id]}
  end

  def destroy
    # When user clicks dislike, it looks up the tweet, destroys a like and then broadcasts the updated count to all the users. Finally, to update the buttons correctly for the user, a format.turbo_stream request is made with the value of @og instead of @tweet, because @tweet is the tweet when it wasn't yet updated with the like count, so it could induce errors. By using @og, it is ensured that the most updated version of the count is shown

    @tweet = Tweet.find(like_params[:tweet_id])
    @like = current_user.liked_tweets.find_by(tweet: @tweet)
    @like.destroy

    @og = @like.tweet

    @og.broadcast_update_later_to "likes",
      partial: "likes/update_likes_count",
      locals: {t: Tweet.find(@tweet.id)}

    respond_to do |format|
      format.turbo_stream { render "likes/replace_likes", locals: {t: @og, user: current_user} }
      format.html { redirect_to request.referrer }
      @tweet.author.notifications_received.where(notifier_id: current_user.id, notification_type: :like, tweet_id: @tweet.id).delete_all
    end
  rescue NoMethodError
    # If a user did already dislike (same session on 2 different tabs for example), it would invoke a NoMethodError, as @like would return nil and nil can't have a #destroy method executed on it, so in that case, no data manipulation is to happen and a turbo request for a simple visual update is made
    flash.now[:alert] = "Can't dislike it twice."
    render "likes/replace_likes", locals: {t: @tweet, user: current_user}
  rescue ActiveRecord::RecordNotFound
    flash.now[:alert] = "Couldn't dislike a deleted tweet."
    render "tweets/_not_found", locals: {id: like_params[:tweet_id]}
  end

  private

  def like_params
    params.require(:like).permit(:tweet_id)
  end
end
