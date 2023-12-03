module ApplicationHelper
  def backdrop
    content_tag(:div, "", id: "backdrop", class: "hidden fixed top-0 left-0 z-10 w-screen h-full scale-[2]")
  end

  def reposts_private_validation(post)
    !post.author.account.private_visibility || (post.author.account.private_visibility && (current_user == post.author || post.reposted_by?(current_user)))
  end

  def quote_button_validation(post)
    !post.author.account.private_visibility || (post.author.account.private_visibility && (current_user == post.author))
  end

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
