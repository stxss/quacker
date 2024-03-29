module IconsHelper
  def like_btn_icon(post)
    like_status = post.liked_by?(current_user) ? "fill-liked stroke-liked" : "fill-none"
    inline_svg_tag("svg/heart.svg", class: like_status.to_s)
  end

  def liked_class(post)
    "text-liked" if post.liked_by?(current_user)
  end

  def bookmark_btn_icon(post)
    bookmark_status = post.bookmarked_by?(current_user) ? "fill-bookmarked stroke-bookmarked" : "fill-none"
    inline_svg_tag("svg/bookmark.svg", class: bookmark_status.to_s)
  end

  def bookmarked_class(post)
    "text-bookmarked" if post.bookmarked_by?(current_user)
  end

  def repost_btn_icon(post, submit = false)
    if post.reposted_by?(current_user)
      repost_status = "stroke-reposted"
      submit_content = "Undo Repost"
    else
      repost_status = ""
      submit_content = "Repost"
    end

    opacity = (post.author.account.private_visibility && current_user != post.author) ? "opacity-50" : ""
    repost_status += opacity
    svg = inline_svg_tag("svg/repost.svg", class: repost_status)
    if submit
      text_submit = content_tag(:p, submit_content)
      content = content_tag(:div, svg + text_submit, class: "flex gap-2 w-full whitespace-nowrap #{repost_status}")
      type = "submit"
    else
      counter = content_tag(:div, post.reposts_count, id: dom_id(post, :reposts_count))
      content = content_tag(:div, svg + counter, class: "flex gap-2 #{repost_status}")
      type = "button"
    end
    ((!post.reposted_by?(current_user) || current_user == post.author || !post.author.account.private_visibility) && submit) ? content_tag(:div, content, class: "flex") : button_tag(type: type, class: "flex") { content }
  end

  def reposted_class(post)
    "text-reposted" if post.reposted_by?(current_user)
  end

  def quote_btn_icon(post)
    repost_status = post.reposted_by?(current_user) ? "stroke-reposted" : "stroke-text"
    svg = inline_svg_tag("svg/quote.svg", class: "fill-none #{repost_status}")
    text_submit = content_tag(:p, "Quote")
    content = content_tag(:div, svg + text_submit, class: "flex gap-2 w-full whitespace-nowrap")
    content_tag(:div, content, class: "flex")
  end

  def comment_btn_icon(post)
    comment_status = post.commented_by?(current_user) ? "stroke-comment" : ""
    svg = inline_svg_tag("svg/comment.svg", class: "#{comment_status}")
    content_tag(:div, svg)
  end

  def commented_class(post)
    "text-comment" if post.commented_by?(current_user)
  end

  def more_info_btn_icon
    button_tag(type: "button") { inline_svg_tag("svg/ellipsis.svg", class: "") }
  end

  def share_btn_icon
    button_tag(type: "button") { inline_svg_tag("svg/share.svg", class: "") }
  end

  def copy_link_btn_icon
    button_tag(type: "button", class: "flex gap-2 align-middle") { inline_svg_tag("svg/link.svg", class: "stroke-text") + "Copy Link to Post" }
  end

  def share_via_message_btn_icon
    content_tag(:div, inline_svg_tag("svg/send_via_message.svg", class: "stroke-text") + "Send via Direct Message", class: "flex gap-2 align-middle")
  end

  def send_message_icon
    button_tag(type: "submit", disabled: true, class: "disabled:opacity-50", data: {"message-target": "submit"}) { inline_svg_tag("svg/send_message.svg", class: "stroke-text") }
  end

  def new_conversation_icon
    content_tag(:div, inline_svg_tag("svg/envelope_plus.svg", class: "stroke-text m-2 bg-clip-padding"), class: "flex gap-1 align-middle items-center justify-end p-2")
  end

  def delete_btn_icon
    content_tag(:div, inline_svg_tag("svg/trash.svg", class: "text-red-600") + "Delete", class: "flex gap-2 align-middle")
  end

  def pin_btn_icon
    content_tag(:div, inline_svg_tag("svg/pin.svg", class: "stroke-text") + "Pin to your Profile", class: "flex gap-2 align-middle")
  end

  def change_who_can_reply_btn_icon
    content_tag(:div, inline_svg_tag("svg/change_replies.svg", class: "stroke-text") + "Change who can reply", class: "flex gap-2 align-middle")
  end

  def limited_repost_btn_icon
    inline_svg_tag("svg/repost.svg", class: "fill-none stroke-text opacity-50")
  end

  def lock_icon
    inline_svg_tag("svg/lock.svg", class: "")
  end

  def expand_replies_icon
    inline_svg_tag("svg/double_arrow.svg", class: "hidden")
  end

  def close_icon
    content_tag(:div, inline_svg_tag("svg/x-close.svg", class: "close-button fill-text stroke-text relative flex justify-end", data: {action: "click->turbo-modal#close"}), class: "flex align-middle justify-end mb-2")
  end
end
