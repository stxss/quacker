class Tweets::BookmarksController < ApplicationController
  include ActionView::RecordIdentifier

  before_action :authenticate_user!
  before_action :set_post, only: :update

  def index
    @bookmarks = current_user.bookmarked_tweets.reject { |tweet| tweet.author.account.has_blocked?(current_user) || current_user.account.has_blocked?(tweet.author) }
    render template: "bookmarks/index"
  end

  def update
    if @post.bookmarked_by?(current_user)
      @post.unbookmark(current_user)
      bookmark_message = "Post removed from bookmarks"
      removed = true
    else
      @post.bookmark(current_user)
      bookmark_message = "Post added to bookmarks"
    end

    respond_to do |format|
      format.turbo_stream {
        flash.now[:notice] = bookmark_message
        render turbo_stream: turbo_stream.replace_all("##{dom_id(@post, :bookmarks)}", partial: "tweets/bookmarks", locals: {t: @post})
      }
      @post.broadcast_render_later_to "bookmarks",
        partial: "tweets/broadcast_bookmarks",
        locals: {t: @post}

      if removed
        @post.broadcast_render_later_to "bookmarks_index",
          partial: "bookmarks/remove_bookmark",
          locals: {t: @post}
      end
    end
  end

  private

  def set_post
    @post = Tweet.find(params[:tweet_id])
  rescue ActiveRecord::RecordNotFound
    flash.now[:alert] = "Tweet not found."
    render "tweets/_not_found", locals: {id: params[:tweet_id]}
  end
end
