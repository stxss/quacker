module Relevance
  extend ActiveSupport::Concern

  included do
    def update_relevance(model, action, tweet, original = nil) # original == root == parent
      # The confidence sort. http://www.evanmiller.org/how-not-to-sort-by-average-rating.html

      lc = tweet.likes_count
      rc = tweet.retweets_count
      cc = tweet.comments_count
      qc = tweet.quote_tweets_count
      total = lc + rc + cc + qc

      # weights
      rw = qw = 0.95
      cw = 0.8
      lw = 0.5

      parameter = case model
      when :like
        lc * lw
      when :retweet
        rc * rw
      when :quote
        qc * qw
      when :comment
        cc * cw
      end

      confidence = 1.281551565545 # 80% confidence
      positive_ratio = parameter.to_f / total

      score = ((positive_ratio + confidence**2 / (2 * total) - confidence * Math.sqrt((positive_ratio * (1 - positive_ratio) + confidence**2 / (4 * total)) / total)) / (1 + confidence**2 / total))

      score = 0.0 if score.nan?

      case action
      when :create
        tweet.update_columns(relevance: tweet.relevance + score)
      when :destroy
        tweet.update_columns(relevance: tweet.relevance - score)
      end
    end
  end
end
