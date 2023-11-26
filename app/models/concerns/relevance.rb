module Relevance
  extend ActiveSupport::Concern

  included do
    def update_relevance(model, action, post, original = nil) # original == root == parent
      # The confidence sort. http://www.evanmiller.org/how-not-to-sort-by-average-rating.html

      return if post.nil?

      weights = {
        comment: 0.0001,
        like: 0.00005,
        quote: 0.0002,
        repost: 0.0002
      }
      weight = weights[model].to_d

      case action
      when :create
        post.update_columns(relevance: post.relevance + weight)
      when :destroy
        post.update_columns(relevance: post.relevance - weight)
      else
        raise StandardError.new("Invalid action")
      end
    end
  end
end
