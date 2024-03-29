class PostsController < ApplicationController
  class UserGonePrivate < StandardError; end

  class UnauthorizedElements < StandardError; end

  # skip_before_action :set_referrer, only: [:new]

  before_action :first_visit?, :set_cache_headers, only: [:index]
  before_action :load_posts, only: [:index, :new]
  after_action :refresh_comments, only: [:index]

  def new
    # If a request there's no request referrer, meaning it was typed into the url bar or a page refresh, basically everything that's not a click on any of the compose buttons, render the normal post_form and timeline
    @render_everything = request.referrer.nil?

    raise UserGonePrivate if @repost && @repost.author.account.private_visibility && current_user != @repost.author
  rescue UserGonePrivate
    respond_to do |format|
      format.html { redirect_to root_path, alert: "Couldn't repost a privated post" }
    end
  rescue ActiveRecord::RecordNotFound, NoMethodError
    flash.now[:alert] = "Something went wrong, please try again!"
    render partial: "posts/not_found", locals: {id: (params[:original_post_id] || params[:parent_id])}
  end

  def index
    if session[:new_comment]&.< 2
      session[:new_comment] += 1
    elsif session[:new_comment]&.>= 2
      session.delete(:new_comment)
    end
  end

  def show
    @post = if Post.with_deleted.find(params[:id]).type.in?(%w[Repost Quote Comment])
      Post.with_deleted.includes({original: [author: :account]}, {comments: [{comments: {author: :account}}, {author: :account}]}, author: :account).find(params[:id])
    else
      Post.with_deleted.includes({comments: [{comments: {author: :account}}, {author: :account}]}, author: :account).find(params[:id])
    end
  rescue ActiveRecord::RecordNotFound
    @post = nil
  end

  def view_blocked_single_post
    @post = Post.find(params[:id])
    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: turbo_stream.replace(
          "post_#{params[:id]}",
          partial: "posts/single_post",
          locals: {post: @post, view: :timeline}
        )
      }
      format.html {}
    end
  end

  def create
    @post = current_user.created_posts.build(post_params)

    respond_to do |format|
      if @post.save
        format.turbo_stream
        format.html { redirect_to root_path }
      end
    end
  end

  def destroy
    @post = Post.find(params[:id])
    repost_ids = @post.reposts.ids

    if current_user == @post.author
      (@post.height > 0) ? @post.soft_destroy : @post.destroy
    else
      raise(UnauthorizedElements)
    end

    respond_to do |format|
      format.turbo_stream { render "shared/destroy", locals: {post: @post, repost_ids: repost_ids} }
      format.html { redirect_to request.referrer }
      Notification.where(post_id: @post.id).delete_all
    end
  rescue ActiveRecord::RecordNotFound, NoMethodError
    flash.now[:alert] = "Something went wrong, please try again!"
    render partial: "posts/not_found", locals: {id: params[:id]}
  rescue UnauthorizedElements
    flash.now[:alert] = "Something went wrong, please try again!"
    render partial: "posts/replace_posts", locals: {id: params[:id]}
  end

  private

  def post_params
    params.require(:post).permit(:body)
  end

  def first_visit?
    session[:first_visit] = current_user.sign_in_count == 1 && session[:first_visit].nil?
  end

  def load_posts
    following_ids = current_user.active_follows.where(is_request: false).pluck(:followed_id)
    query = "user_id = :current_user_id OR user_id IN (:following_ids)"

    reposts ||= Repost.where(query, current_user_id: current_user.id, following_ids: following_ids).includes({original: [author: :account]}, author: :account)
    quotes ||= Quote.where(query, current_user_id: current_user.id, following_ids: following_ids).includes({original: [author: :account]}, {comments: [{comments: {author: :account}}, {author: :account}]}, author: :account)
    normal ||= Post.where(query, current_user_id: current_user.id, following_ids: following_ids).where(type: nil).includes({comments: [{comments: {author: :account}}, {author: :account}]}, author: :account)

    # reject muted. blocked accounts are unfollowed, so if the blocked user has commented on something that the blocker posted, it will be hidden from the timeline or a specific message shown as a disclaimer saying that the user is blocked, with a button to fetch that specific post in case the user wishes to see the content of the post, with only reposts being filtered
    muted_accounts = current_user.account.muted_accounts.pluck(:muted_id)
    blocked_accounts = current_user.account.blocked_accounts.pluck(:blocked_id)
    muted_words = current_user.account.muted_words.pluck(:body)

    @posts = (normal + reposts + quotes).reject do |post|
      author = post.author
      next if author == current_user

      muted_author = muted_accounts.include?(author.id)
      original_post = post.original if !post.type.nil?
      parent_author = original_post.author if original_post
      author_blocked_current = !post.type.nil? && parent_author.account.has_blocked?(current_user)

      has_muted_word = muted_words.any? do |muted_word|
        to_check = post.type.nil? ? post.body : original_post.body

        # if the current user posts a word they muted, show the word, because why would they mute it if they are posting about it
        to_check.include?(muted_word) && author != current_user
      end

      muted_author || author_blocked_current || has_muted_word
    end.sort_by(&:updated_at).reverse!
  end

  def set_cache_headers
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

  def refresh_comments
    return unless session[:new_comment]

    # THIS IS THE COMMENT
    comment = Comment.find_by(id: session[:og_comment_id])

    # THIS IS THE PARENT COMMENT
    comment&.original&.update(updated_at: comment.created_at)

    session.delete(:og_comment_id)
  end
end
