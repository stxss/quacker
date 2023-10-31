module Reusable
  # ! INTERNAL_HOST = ActionMailer::Base.default_url_options[:host]
  INTERNAL_HOST = "example.com"
  INTERNAL_SCHEME = "https"
  URL_REGEX = /(https?:\/\/)?\w*\.\w+(\.\w+)*(\/\w+)*(\.\w*)?/
  USERNAME_POST_REGEX = /\/([^\/]+)\/status\/(\d+)(\/)?$/

  def parse_url(url)
    uri = URI.parse(url)
    uri.scheme ||= INTERNAL_SCHEME
    uri.host ||= INTERNAL_HOST
    uri
  end

  def find_post_by_internal_url
    @post ||= Set.new

    body.gsub(URL_REGEX) do |url|
      @url = parse_url(url)
      next if @url.host != INTERNAL_HOST || @url.path.blank?

      @username, @post_id = @url.path.match(USERNAME_POST_REGEX)&.captures

      @user = User.find_by(username: @username) || nil
      next if !@user

      @post << @user.created_tweets.find_by(id: @post_id)
    end

    return @post.compact unless @post.nil?

    false
  rescue URI::BadURIError, URI::InvalidURIError
    false
  end

  def urlize
    body.gsub!(URL_REGEX) do |url|
      URI.parse(url).scheme.nil? ? "https://#{url}" : url
    end

    replace_urls
    body
  rescue URI::BadURIError, URI::InvalidURIError
    false
  end

  def replace_urls
    extracted = URI.extract(body, ["http", "https"])
    body.split(/\s+/).each_with_index do |word, i|
      body.gsub!(word, extracted.shift) if word.match?(URL_REGEX)
    end
  end

  def extract_msg_comment
    arr = body.split(/((?:https?:\/\/)?(?:[\w.-]+\.[a-z]+)(?:\/[^?\s]*)+)/)
    arr.reject! do |w|
      w.blank? || w.match?(/((?:https?:\/\/)?(?:[\w.-]+\.[a-z]+)(?:\/[^?\s]*)+)/)
    end
  end
end
