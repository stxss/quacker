class SearchController < ApplicationController
  def index
    @query = Tweet.ransack(params[:q])
    @posts = @query.result(distinct: true).includes(:author, :likes, :comments, :retweets, :quote_tweets).order(created_at: :desc)
  end
end
