module ApplicationHelper
  def lock_icon_svg
    content_tag(:svg, id: "icon-lock") do
      content_tag(:path, "", d: "M17.5 7H17v-.25c0-2.76-2.24-5-5-5s-5 2.24-5 5V7h-.5C5.12 7 4 8.12 4 9.5v9C4 19.88 5.12 21 6.5 21h11c1.39 0 2.5-1.12 2.5-2.5v-9C20 8.12 18.89 7 17.5 7zM13 14.73V17h-2v-2.27c-.59-.34-1-.99-1-1.73 0-1.1.9-2 2-2 1.11 0 2 .9 2 2 0 .74-.4 1.39-1 1.73zM15 7H9v-.25c0-1.66 1.35-3 3-3 1.66 0 3 1.34 3 3V7z")
    end
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
end
