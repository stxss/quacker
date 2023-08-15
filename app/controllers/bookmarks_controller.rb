class BookmarksController < ApplicationController
  def index
    @bookmarks = current_user.bookmarked_tweets
  end

  def create
    @bookmark = current_user.bookmarks.build(bookmark_params)
    @tweet = @bookmark.tweet

    raise ActiveRecord::RecordNotFound if @tweet.nil?

    @bookmark.tweet.broadcast_render_later_to "bookmarks",
      partial: "bookmarks/update_bookmark_count",
      locals: {t: @bookmark.tweet}

    respond_to do |format|
      if @bookmark.save
        format.turbo_stream {
          render turbo_stream: [
            turbo_stream.replace_all(".menuitem #bookmark_#{@bookmark.tweet.id}", partial: "bookmarks/bookmarks", locals: {t: @bookmark.tweet})
          ]
        }
        format.html { redirect_to request.referrer }
      end
    end
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.remove("tweet_#{bookmark_params[:tweet_id]}"),
          flash.now[:alert] = "Can't bookmark a deleted Tweet"
        ]
      }
    end
  rescue ActiveRecord::RecordNotUnique, NoMethodError
    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.replace_all(".menuitem #bookmark_#{@tweet.id}", partial: "bookmarks/bookmarks", locals: {t: @tweet})
        ]
      }
    end
  end

  def destroy
    @tweet = Tweet.find(params[:id])
    @bookmark = current_user.bookmarks.find_by(tweet_id: @tweet.id).destroy

    @bookmark.tweet.broadcast_render_later_to "bookmarks",
      partial: "bookmarks/update_bookmark_count",
      locals: {t: @bookmark.tweet}

    @bookmark.tweet.broadcast_render_later_to "bookmarks_index",
      partial: "bookmarks/remove_bookmark",
      locals: {t: @bookmark.tweet}

    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.replace_all(".menuitem #bookmark_#{@bookmark.tweet.id}", partial: "bookmarks/bookmarks", locals: {t: @bookmark.tweet})
        ]
      }
      format.html { redirect_to request.referrer }
    end
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.remove("tweet_#{params[:id]}"),
          flash.now[:alert] = "Can't unbookmark a deleted Tweet"
        ]
      }
    end
  rescue NoMethodError
    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.replace_all(".menuitem #bookmark_#{params[:id]}", partial: "bookmarks/bookmarks", locals: {t: Tweet.find(params[:id])})
        ]
      }
    end
  end

  private

  def bookmark_params
    params.require(:bookmark).permit(:tweet_id)
  end
end
