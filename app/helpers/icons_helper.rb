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
end
