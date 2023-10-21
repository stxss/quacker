class BookmarksController < ApplicationController
  def index
    @bookmarks = current_user.bookmarked_tweets.reject { |tweet| tweet.author.account.has_blocked?(current_user) || current_user.account.has_blocked?(tweet.author) }
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
          flash.now[:notice] = "Post added to bookmarks"
          render "bookmarks/replace_bookmarks", locals: {t: @bookmark.tweet}
        }
        format.html { redirect_to request.referrer }
      end
    end
  rescue ActiveRecord::RecordNotFound
    flash.now[:alert] = "Can't bookmark a deleted Tweet"
    render "tweets/_not_found", locals: {id: bookmark_params[:tweet_id]}
  rescue ActiveRecord::RecordNotUnique, NoMethodError
    flash.now[:alert] = "Can't bookmark twice"
    render "bookmarks/replace_bookmarks", locals: {t: @tweet }
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
        flash.now[:notice] = "Post removed from bookmarks"
        render "bookmarks/replace_bookmarks", locals: {t: @bookmark.tweet}
      }
      format.html { redirect_to request.referrer }
    end
  rescue ActiveRecord::RecordNotFound
    flash.now[:alert] = "Can't unbookmark a deleted Tweet"
    render "tweets/_not_found", locals: {id: params[:id]}
  rescue NoMethodError
    flash.now[:alert] = "Can't unbookmark twice"
    render "bookmarks/replace_bookmarks", locals: {t: Tweet.find(params[:id])}
  end

  private

  def bookmark_params
    params.require(:bookmark).permit(:tweet_id)
  end
end
