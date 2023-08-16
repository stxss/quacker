class RetweetsController < TweetsController
  def create
    # When user clicks retweet, it looks up the tweet, creates a retweet and then broadcasts the updated count to all the users. Finally, to update the buttons correctly for the user, a format.turbo_stream request is made with the value of the tweet as the original has been updated with a retweet count. By fetching the original tweet after the update, the most recent values are assured and errors minimized

    @retweet = current_user.created_retweets.build(retweet_params)

    @retweet.original.broadcast_render_later_to "retweets",
      partial: "retweets/update_retweets_count",
      locals: {t: @retweet.original}

    raise UserGonePrivate if @retweet.original.author.account.private_visibility && current_user != @retweet.original.author

    respond_to do |format|
      if @retweet.save
        format.turbo_stream {
          render turbo_stream: [
            turbo_stream.replace_all("#retweet_#{@retweet.original.id}", partial: "retweets/retweets", locals: {t: @retweet.original, user: current_user})
          ]
        }
        format.html { redirect_to request.referrer }
        current_user.notify(@retweet.original.author.id, :retweet, tweet_id: @retweet.original.id)
      end
    end
  rescue ActiveRecord::RecordNotUnique
    # If a user already has a retweet, it would invoke a ActiveRecord::RecordNotUnique error, so in that case, no data manipulation is to happen and a turbo request for a simple visual update is made

    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.replace_all("#retweet_#{@retweet.original.id}", partial: "retweets/retweets", locals: {t: @retweet.original, user: current_user})
        ]
      }
    end
  rescue ActiveRecord::RecordNotFound, NoMethodError
    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.remove("tweet_#{retweet_params[:retweet_id]}"),
          flash.now[:alert] = "Couldn't retweet."
        ]
      }
    end
  rescue UserGonePrivate
    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.replace_all("#retweet_#{@retweet.original.id} .dropdown", partial: "retweets/fake_retweet_menu", locals: {t: @retweet.original}),
          flash.now[:alert] = "Couldn't retweet a privated tweet"
        ]
      }
    end
  end

  def destroy
    # When user clicks undo retweet, it looks up the tweet, destroys the retweet and then broadcasts the updated count to all the users. Finally, to update the buttons correctly for the user, a format.turbo_stream request is made with the value of @retweet.original By using @retweet.original (meaning, the tweet after the unretweet action), it is ensured that the most updated version of the count is shown

    @original = Tweet.find(retweet_params[:retweet_id])

    @retweet = current_user.created_retweets.find_by(retweet_id: retweet_params[:retweet_id])
    @retweet.destroy

    # @retweet.original is the updated version of the tweet
    @retweet.original.broadcast_render_later_to "retweets",
      partial: "retweets/update_retweets_count",
      locals: {t: @retweet.original}

    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.remove("tweet_#{@retweet.id}"),
          turbo_stream.replace_all("#retweet_#{@retweet.original.id}", partial: "retweets/retweets", locals: {t: @retweet.original, user: current_user})
        ]
      }
      format.html { redirect_to request.referrer }
      @retweet.original.author.notifications_received.where(notifier_id: current_user.id, notification_type: :retweet, tweet_id: @retweet.original.id).delete_all
    end
  rescue NoMethodError
    # If a user did already unretweet (same session on 2 different tabs for example), it would invoke a NoMethodError, as @retweet would return nil and nil can't have a #destroy method executed on it, so in that case, no data manipulation is to happen and a turbo request for a simple visual update is made with the original version - @original. @retweet.original couldn't be used as it is only defined after the unretweet is made

    respond_to do |format|
      @to_remove = if @retweet
        turbo_stream.remove("tweet_#{@retweet.id}")
      else
        turbo_stream.remove("tweet_#{retweet_params[:self_rt]}")
      end

      format.turbo_stream {
        render turbo_stream: [
          @to_remove,
          turbo_stream.replace_all("#retweet_#{@original.id}", partial: "retweets/retweets", locals: {t: @original, user: current_user})
        ]
      }
    end
  end

  private

  def retweet_params
    params.require(:retweet).permit(:retweet_id, :self_rt)
  end
end
