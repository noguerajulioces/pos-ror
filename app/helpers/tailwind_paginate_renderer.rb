# app/helpers/tailwind_paginate_renderer.rb
class TailwindPaginateRenderer < WillPaginate::ActionView::LinkRenderer
  def html_container(html)
    tag :div, html, class: "mt-4 justify-center flex"
  end

  def page_number(page)
    if page == current_page
      tag :span, page, class: "mx-1 px-3 py-1 rounded-md bg-indigo-600 text-white font-medium"
    else
      tag :a, page, href: url(page), class: "mx-1 px-3 py-1 rounded-md text-indigo-600 hover:bg-indigo-100 font-medium"
    end
  end

  def previous_or_next_page(page, text, classname, disabled_class = nil)
    clean_text = text.gsub(/&.*?;/, "").strip.downcase

    icon = case clean_text
    when "previous"
             "←"
    when "next"
             "→"
    else
             ""
    end
    if page
      tag :a, icon, href: url(page), class: "mx-1 px-3 py-1 rounded-md text-indigo-600 hover:bg-indigo-100 font-medium"
    else
      tag :span, icon, class: "mx-1 px-3 py-1 rounded-md text-gray-400 font-medium"
    end
  end

  def gap
    tag :span, "...", class: "mx-1 px-3 py-1 rounded-md text-gray-600 font-medium"
  end
end
