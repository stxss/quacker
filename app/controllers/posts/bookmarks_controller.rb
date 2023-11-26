class Posts::BookmarksController < ApplicationController
  include ActionView::RecordIdentifier

  before_action :authenticate_user!
  before_action :set_post, only: :update

  def index
    @bookmarks = current_user.bookmarked_posts.reject { |post| post.author.account.has_blocked?(current_user) || current_user.account.has_blocked?(post.author) }
    render template: "bookmarks/index"
  end

  def update
    if @post.bookmarked_by?(current_user)
      @post.unbookmark(current_user)
      @bookmark_message = "Post removed from bookmarks"
      @removed = true
    else
      @post.bookmark(current_user)
      @bookmark_message = "Post added to bookmarks"
    end

    respond_to do |format|
      format.turbo_stream {
        flash.now[:notice] = @bookmark_message
        render turbo_stream: turbo_stream.replace_all("##{dom_id(@post, :bookmarks)}", partial: "posts/bookmarks", locals: {post: @post})
      }
      @post.broadcast_render_later_to "bookmarks",
        partial: "posts/broadcast_bookmarks",
        locals: {post: @post}

      if @removed
        @post.broadcast_render_later_to "bookmarks_index",
          partial: "bookmarks/remove_bookmark",
          locals: {post: @post}
      end
    end
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  rescue ActiveRecord::RecordNotFound
    flash.now[:alert] = "Post not found."
    render partial: "posts/not_found", locals: {id: params[:post_id]}
  end
end
