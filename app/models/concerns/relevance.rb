module Relevance
  extend ActiveSupport::Concern

  included do
    def update_relevance(model, action, tweet, original = nil) # original == root == parent
      # The confidence sort. http://www.evanmiller.org/how-not-to-sort-by-average-rating.html

      return if tweet.nil?

      # weights
      rw = qw = 0.0002
      cw = 0.0001
      lw = 0.00005

      weight = case model
      when :like
        lw
      when :repost
        rw
      when :quote
        qw
      when :comment
        cw
      end.to_d

      case action
      when :create
        tweet.update_columns(relevance: tweet.relevance + weight)
      when :destroy
        tweet.update_columns(relevance: tweet.relevance - weight)
      end
    end
  end
end
