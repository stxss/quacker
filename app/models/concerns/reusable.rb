module Reusable
  def urlize
    body.gsub!(/\b(https?:\/\/)?\w+\.\w+(\.\w+)*(\/\w+)*(\.\w*)?\b/) do |url|
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
      body.gsub!(word, extracted.shift) if word =~ /(https?:\/\/)?\w*\.\w+(\.\w+)*(\/\w+)*(\.\w*)?/
    end
  end
end
