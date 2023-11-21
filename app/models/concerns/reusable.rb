require "./lib/constants/tlds"

module Reusable
  # ! INTERNAL_HOST = ActionMailer::Base.default_url_options[:host]
  INTERNAL_HOST = "example.com"
  INTERNAL_SCHEME = "https"

  # credit to https://gist.github.com/dperini/729294 for this regex for filtering urls, as it is one of the most complete that i could find https://mathiasbynens.be/demo/url-regex. Although I had to add a small '?' after the scheme, as in my use case it is optional, because i make necessary validations, meaning that if it isn't there, i add a 'https://' to it and visually take it away afterwards, for a cleaner look
  URL_REGEX = /^(?:(?:(?:https?|ftp):)?\/\/)?(?:\S+(?::\S*)?@)?(?:(?!(?:10|127)(?:\.\d{1,3}){3})(?!(?:169\.254|192\.168)(?:\.\d{1,3}){2})(?!172\.(?:1[6-9]|2\d|3[0-1])(?:\.\d{1,3}){2})(?:[1-9]\d?|1\d\d|2[01]\d|22[0-3])(?:\.(?:1?\d{1,2}|2[0-4]\d|25[0-5])){2}(?:\.(?:[1-9]\d?|1\d\d|2[0-4]\d|25[0-4]))|(?:(?:[a-z0-9\u00a1-\uffff][a-z0-9\u00a1-\uffff_-]{0,62})?[a-z0-9\u00a1-\uffff]\.)+(?:[a-z\u00a1-\uffff]{2,}\.?))(?::\d{2,5})?(?:[\/?#]\S*)?$/i

  SCHEME_ONLY_REGEX = /(https?:\/\/)?(www\.)?/
  USERNAME_POST_REGEX = /\/([^\/]+)\/status\/(\d+)(\/)?$/

  def parse_url(url)
    uri = URI.parse(url)
    uri.scheme ||= INTERNAL_SCHEME
    uri.host ||= INTERNAL_HOST
    uri
  end

  def find_post_by_internal_url
    @post ||= Set.new

    # rstrip because in MessageCreator, i have `@url << " " << @body` in case a user also adds a comment. And if they have no body, i prefer doing the strip here, as for some reason stripping in the creator does lead to bugs
    body.rstrip.gsub(URL_REGEX) do |url|
      @url = parse_url(url)
      # @url.host[4..] because if for some reason the host is retrieved as `www.example.com`, with the "www" present, compare the 'cut off' version
      host_to_compare = @url.host.start_with?("www.") ? @url.host[4..] : @url.host
      next if host_to_compare != INTERNAL_HOST || @url.path.blank?

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

  # when creating a tweet or a message, this method validates any urls present and passes them on to the markdown method in the application helper, to create hyperlinks automatically.
  def validate_urls(text = nil)
    return if self.instance_of?(Retweet)

    content = text || body

    content.split(/[,:\s]|(\/\/)+/).each do |test_url|
      next if !test_url.downcase.match?(URL_REGEX)
      # force downcase as uppercase urls, 1st are invalid, 2nd break the uri parser
      downcased = test_url.downcase

      parsed_uri = URI.parse(downcased)
      scheme = parsed_uri.scheme || "https://"

      #  "//#{parsed_uri}" the double slash is needed because if not added witll throw  a `both uri are relative` error
      filtered_url = URI.join(scheme, "//#{parsed_uri}")

      tld = filtered_url.host.upcase.split(".")[-1]
      tld_validity = Constants::Tlds.valid.include?(tld)

      # if tld isn't valid, basically 'return' the string as it was, without hyperlinking it, otherwise, create a valid link and prepend it with https
      if !tld_validity
        content.gsub!(filtered_url.to_s, parsed_uri.path)
      else
        to_replace = if test_url.start_with?("http://", "https://")
          test_url
        elsif test_url != ("https://#{test_url}")
          (test_url.include?("www.") ? "https://#{test_url}" : "https://www." << test_url)
        end
        # case insensitive
        cond = /(\s{0}|^)((https?:\/\/)?(www\.)?#{Regexp.escape(test_url)})/

        content.gsub!(cond, to_replace)
      end
    end
    # correct the values of the links in the body, so there is no need to validate the links time and time again in the future, as this operation is made only once before saving the tweets/messages
    self.body = content.rstrip
  rescue URI::BadURIError, URI::InvalidURIError
    false
  end

  def extract_msg_comment
    arr = body.split(/((?:https?:\/\/)?(?:[\w.-]+\.[a-z]+)(?:\/[^?\s]*)+)/)
    arr.reject! do |w|
      w.blank? || w.match?(/((?:https?:\/\/)?(?:[\w.-]+\.[a-z]+)(?:\/[^?\s]*)+)/)
    end
  end
end
