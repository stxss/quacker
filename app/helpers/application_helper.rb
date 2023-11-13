module ApplicationHelper
  def lock_icon_svg
    content_tag(:svg, class: "icon-lock") do
      content_tag(:path, "", d: "M17.5 7H17v-.25c0-2.76-2.24-5-5-5s-5 2.24-5 5V7h-.5C5.12 7 4 8.12 4 9.5v9C4 19.88 5.12 21 6.5 21h11c1.39 0 2.5-1.12 2.5-2.5v-9C20 8.12 18.89 7 17.5 7zM13 14.73V17h-2v-2.27c-.59-.34-1-.99-1-1.73 0-1.1.9-2 2-2 1.11 0 2 .9 2 2 0 .74-.4 1.39-1 1.73zM15 7H9v-.25c0-1.66 1.35-3 3-3 1.66 0 3 1.34 3 3V7z")
    end
  end

  def retweet_icon_svg
    content_tag(:svg, class: "icon-retweet") do
      content_tag(:path, "", d: "M4.5 3.88l4.432 4.14-1.364 1.46L5.5 7.55V16c0 1.1.896 2 2 2H13v2H7.5c-2.209 0-4-1.79-4-4V7.55L1.432 9.48.068 8.02 4.5 3.88zM16.5 6H11V4h5.5c2.209 0 4 1.79 4 4v8.45l2.068-1.93 1.364 1.46-4.432 4.14-4.432-4.14 1.364-1.46 2.068 1.93V8c0-1.1-.896-2-2-2z")
    end
  end

  def like_icon_svg
    content_tag(:svg, class: "icon-like stroke-1 ") do
      content_tag(:path, "", d: "M16.697 5.5c-1.222-.06-2.679.51-3.89 2.16l-.805 1.09-.806-1.09C9.984 6.01 8.526 5.44 7.304 5.5c-1.243.07-2.349.78-2.91 1.91-.552 1.12-.633 2.78.479 4.82 1.074 1.97 3.257 4.27 7.129 6.61 3.87-2.34 6.052-4.64 7.126-6.61 1.111-2.04 1.03-3.7.477-4.82-.561-1.13-1.666-1.84-2.908-1.91zm4.187 7.69c-1.351 2.48-4.001 5.12-8.379 7.67l-.503.3-.504-.3c-4.379-2.55-7.029-5.19-8.382-7.67-1.36-2.5-1.41-4.86-.514-6.67.887-1.79 2.647-2.91 4.601-3.01 1.651-.09 3.368.56 4.798 2.01 1.429-1.45 3.146-2.1 4.796-2.01 1.954.1 3.714 1.22 4.601 3.01.896 1.81.846 4.17-.514 6.67z")
    end
  end

  def unlike_icon_svg
    content_tag(:svg, class: "icon-unlike") do
      content_tag(:path, "", d: "M20.884 13.19c-1.351 2.48-4.001 5.12-8.379 7.67l-.503.3-.504-.3c-4.379-2.55-7.029-5.19-8.382-7.67-1.36-2.5-1.41-4.86-.514-6.67.887-1.79 2.647-2.91 4.601-3.01 1.651-.09 3.368.56 4.798 2.01 1.429-1.45 3.146-2.1 4.796-2.01 1.954.1 3.714 1.22 4.601 3.01.896 1.81.846 4.17-.514 6.67z")
    end
  end

  def quote_icon_svg
    content_tag(:svg, class: "icon-quote") do
      content_tag(:path, "", d: "M14.23 2.854c.98-.977 2.56-.977 3.54 0l3.38 3.378c.97.977.97 2.559 0 3.536L9.91 21H3v-6.914L14.23 2.854zm2.12 1.414c-.19-.195-.51-.195-.7 0L5 14.914V19h4.09L19.73 8.354c.2-.196.2-.512 0-.708l-3.38-3.378zM14.75 19l-2 2H21v-2h-6.25z")
    end
  end

  def comment_icon_svg
    content_tag(:svg, class: "icon-comment") do
      content_tag(:path, "", d: "M1.751 10c0-4.42 3.584-8 8.005-8h4.366c4.49 0 8.129 3.64 8.129 8.13 0 2.96-1.607 5.68-4.196 7.11l-8.054 4.46v-3.69h-.067c-4.49.1-8.183-3.51-8.183-8.01zm8.005-6c-3.317 0-6.005 2.69-6.005 6 0 3.37 2.77 6.08 6.138 6.01l.351-.01h1.761v2.3l5.087-2.81c1.951-1.08 3.163-3.13 3.163-5.36 0-3.39-2.744-6.13-6.129-6.13H9.756z")
    end
  end

  def more_info_svg
    content_tag(:svg, class: "icon-more-info") do
      content_tag(:path, "", d: "M3 12c0-1.1.9-2 2-2s2 .9 2 2-.9 2-2 2-2-.9-2-2zm9 2c1.1 0 2-.9 2-2s-.9-2-2-2-2 .9-2 2 .9 2 2 2zm7 0c1.1 0 2-.9 2-2s-.9-2-2-2-2 .9-2 2 .9 2 2 2z")
    end
  end

  def share_icon_svg
    content_tag(:svg, class: "icon-share") do
      content_tag(:path, "", d: "M12 2.59l5.7 5.7-1.41 1.42L13 6.41V16h-2V6.41l-3.3 3.3-1.41-1.42L12 2.59zM21 15l-.02 3.51c0 1.38-1.12 2.49-2.5 2.49H5.5C4.11 21 3 19.88 3 18.5V15h2v3.5c0 .28.22.5.5.5h12.98c.28 0 .5-.22.5-.5L19 15h2z")
    end
  end

  def copy_link_svg
    content_tag(:svg, class: "icon-link h-6 w-6") do
      content_tag(:path, "", d: "M18.36 5.64c-1.95-1.96-5.11-1.96-7.07 0L9.88 7.05 8.46 5.64l1.42-1.42c2.73-2.73 7.16-2.73 9.9 0 2.73 2.74 2.73 7.17 0 9.9l-1.42 1.42-1.41-1.42 1.41-1.41c1.96-1.96 1.96-5.12 0-7.07zm-2.12 3.53l-7.07 7.07-1.41-1.41 7.07-7.07 1.41 1.41zm-12.02.71l1.42-1.42 1.41 1.42-1.41 1.41c-1.96 1.96-1.96 5.12 0 7.07 1.95 1.96 5.11 1.96 7.07 0l1.41-1.41 1.42 1.41-1.42 1.42c-2.73 2.73-7.16 2.73-9.9 0-2.73-2.74-2.73-7.17 0-9.9z")
    end
  end

  def send_via_message_svg
    content_tag(:svg, class: "icon-send-via-message h-6 w-6") do
      content_tag(:path, "", d: "M1.998 5.5c0-1.381 1.119-2.5 2.5-2.5h15c1.381 0 2.5 1.119 2.5 2.5v13c0 1.381-1.119 2.5-2.5 2.5h-15c-1.381 0-2.5-1.119-2.5-2.5v-13zm2.5-.5c-.276 0-.5.224-.5.5v2.764l8 3.638 8-3.636V5.5c0-.276-.224-.5-.5-.5h-15zm15.5 5.463l-8 3.636-8-3.638V18.5c0 .276.224.5.5.5h15c.276 0 .5-.224.5-.5v-8.037z")
    end
  end

  def add_bookmark_svg
    content_tag(:svg, class: "icon-bookmark h-6 w-6") do
      content_tag(:path, "", d: "M17 3V0h2v3h3v2h-3v3h-2V5h-3V3h3zM6.5 4c-.276 0-.5.22-.5.5v14.56l6-4.29 6 4.29V11h2v11.94l-8-5.71-8 5.71V4.5C4 3.12 5.119 2 6.5 2h4.502v2H6.5z")
    end
  end

  def remove_bookmark_svg
    content_tag(:svg, class: "icon-bookmark h-6 w-6") do
      content_tag(:path, "", d: "M16.586 4l-2.043-2.04L15.957.54 18 2.59 20.043.54l1.414 1.42L19.414 4l2.043 2.04-1.414 1.42L18 5.41l-2.043 2.05-1.414-1.42L16.586 4zM6.5 4c-.276 0-.5.22-.5.5v14.56l6-4.29 6 4.29V11h2v11.94l-8-5.71-8 5.71V4.5C4 3.12 5.119 2 6.5 2h4.502v2H6.5z")
    end
  end

  def bookmarks_svg
    content_tag(:svg, class: "icon-bookmark h-6 w-6") do
      content_tag(:path, "", d: "M4 4.5C4 3.12 5.119 2 6.5 2h11C18.881 2 20 3.12 20 4.5v18.44l-8-5.71-8 5.71V4.5zM6.5 4c-.276 0-.5.22-.5.5v14.56l6-4.29 6 4.29V4.5c0-.28-.224-.5-.5-.5h-11z")
    end
  end

  # def svg
  #   content_tag(:svg, class: "icon-") do
  #     content_tag(:path, "", d: "")
  #   end
  # end

  # https://www.hotrails.dev/turbo-rails/flash-messages-hotwire
  def render_flash_message
    turbo_stream.prepend("flash", partial: "layouts/flash")
  end

  def formatted_time_ago(created_at)
    seconds_ago = (Time.current - created_at).to_i

    if created_at > 24.hours.ago
      case seconds_ago
      when 0...60
        "#{seconds_ago}s"
      when 60...3600
        "#{(seconds_ago / 60).to_i} min"
      else
        "#{(seconds_ago / 3600).to_i} h"
      end
    elsif created_at.year == Time.current.year
      created_at.strftime("%b %e")
    else
      created_at.strftime("%b %e, %Y")
    end
  end

  def days_left(expiration_date)
    return "Muted Forever" if expiration_date.nil?
    days_left = ((expiration_date - DateTime.now) / 1.day).to_f
    if days_left > 1
      "#{days_left.round}d"
    else
      "#{(days_left * 1.day / 1.hour).to_f.round}h"
    end
  end

  def markdown(tweet)
    options = {
      parse: {
        smart: true
      },
      render: {
        hardbreaks: true,
        github_pre_lang: true,
        escape: true
      },
      extension: {
        superscript: true,
        strikethrough: true,
        table: true
      }
    }

    # superscript is written as n^2^

    content = tweet.body
    result = auto_link(Commonmarker.to_html(content, options: options), html: {class: "text-sky-700 font-semibold", rel: "nofollow", target: "_blank"}, link: :urls) { |url| url.gsub(/(https?:\/\/)?(www\.)?/, "").truncate(20) }

    sanitize(result)
  end
end

# finish up the detail with the messages
