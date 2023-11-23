module IconsHelper
  def like_btn_icon(post)
    like_status = post.liked_by?(current_user) ? "fill-liked stroke-liked" : "fill-none"
    inline_svg_tag("svg/heart.svg", class: "#{like_status} z-10")
  end

  def liked_class(post)
    "text-liked" if post.liked_by?(current_user)
  end

  def bookmark_btn_icon(post)
    bookmark_status = post.bookmarked_by?(current_user) ? "fill-bookmarked stroke-bookmarked" : "fill-none stroke-text"
    inline_svg_tag("svg/bookmark.svg", class: "#{bookmark_status} z-10")
  end

  def bookmarked_class(post)
    "text-bookmarked" if post.bookmarked_by?(current_user)
  end

  def repost_btn_icon(post, submit = false)
    repost_status = post.reposted_by?(current_user) ? "stroke-reposted" : "stroke-text"
    repost_status += " opacity-50" if post.author.account.private_visibility && current_user != post.author
    svg = inline_svg_tag("svg/repost.svg", class: "#{repost_status} z-20")
    if submit
      text_submit = content_tag(:p, "Repost")
      content = content_tag(:div, svg + text_submit, class: "flex gap-2")
      type = "submit"
    else
      counter = content_tag(:div, post.reposts_count, id: dom_id(post, :reposts_count))
      content = content_tag(:div, svg + counter, class: "flex gap-2")
      type = "button"
    end
    (post.reposted_by?(current_user) || current_user == post.author || !post.author.account.private_visibility) ? button_tag(type: type) { content } : content
  end

  def reposted_class(post)
    "text-reposted" if post.reposted_by?(current_user)
  end

end
