class SearchController < ApplicationController
  def index
    return @posts = [] if params[:q].blank? || params[:q].values.first.match?(/^\s*$/)

    @query = Post.ransack(params[:q])
    @posts = @query.result(distinct: true).includes(:author, :likes, :comments, :reposts, :quote_posts).order(created_at: :desc)
  end
end
