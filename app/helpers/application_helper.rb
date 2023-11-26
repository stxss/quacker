module ApplicationHelper
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

  def markdown(post)
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

    content = post.body
    result = auto_link(Commonmarker.to_html(content, options: options), html: {class: "text-sky-700 font-semibold", rel: "nofollow", target: "_blank"}, link: :urls) { |url| url.gsub(/(https?:\/\/)?(www\.)?/, "").truncate(20) }

    sanitize(result)
  end
end

# finish up the detail with the messages
