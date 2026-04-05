module ApplicationHelper
  def stock_status_class(product)
    return '' unless product.stock && product.min_stock
    product.stock <= product.min_stock ? 'bg-red-50' : ''
  end

  def low_stock?(product)
    return false unless product.stock && product.min_stock
    product.stock <= product.min_stock
  end

  def stock_text_color(product)
    low_stock?(product) ? 'text-red-900' : 'text-gray-900'
  end

  def stock_value_color(product)
    low_stock?(product) ? 'text-red-700' : 'text-gray-500'
  end

  def stock_row_class(product)
    return '' unless product.kind == 'simple'
    stock = product.stock.to_i
    min   = product.min_stock
    return 'bg-red-50' if stock <= 0
    return 'bg-amber-50' if min && stock <= min
    ''
  end

  def stock_badge(product)
    case product.kind
    when 'recipe', 'combo'
      virtual = product.virtual_stock.to_i
      if virtual <= 0
        content_tag(:span, 'Sin stock', class: 'inline-flex items-center rounded-full bg-red-100 px-2 py-0.5 text-xs font-medium text-red-700')
      else
        content_tag(:span, 'Disponible', class: 'inline-flex items-center rounded-full bg-green-100 px-2 py-0.5 text-xs font-medium text-green-700')
      end
    else
      stock = product.stock.to_i
      min   = product.min_stock
      if stock <= 0
        content_tag(:span, 'Sin stock', class: 'inline-flex items-center rounded-full bg-red-100 px-2 py-0.5 text-xs font-medium text-red-700')
      elsif min && stock <= min
        content_tag(:span, 'Stock bajo', class: 'inline-flex items-center rounded-full bg-amber-100 px-2 py-0.5 text-xs font-medium text-amber-700')
      else
        content_tag(:span, 'Normal', class: 'inline-flex items-center rounded-full bg-green-100 px-2 py-0.5 text-xs font-medium text-green-700')
      end
    end
  end

  def kind_badge(product)
    case product.kind
    when 'simple'
      content_tag(:span, 'Simple', class: 'inline-flex items-center rounded-full bg-blue-100 px-2 py-0.5 text-xs font-medium text-blue-600')
    when 'recipe'
      content_tag(:span, 'Receta', class: 'inline-flex items-center rounded-full bg-purple-100 px-2 py-0.5 text-xs font-medium text-purple-600')
    when 'combo'
      content_tag(:span, 'Combo', class: 'inline-flex items-center rounded-full bg-orange-100 px-2 py-0.5 text-xs font-medium text-orange-600')
    else
      content_tag(:span, product.kind.to_s.capitalize, class: 'inline-flex items-center rounded-full bg-gray-100 px-2 py-0.5 text-xs font-medium text-gray-600')
    end
  end

  def sidebar_collapsed?
    # For now, always return false to use JavaScript control
    # This will be controlled by the Stimulus controller
    false
  end

  def render_settings_icon(collapsed: false, is_current: false)
    if collapsed
      link_class = is_current ?
        'group flex justify-start items-center rounded-xl bg-gradient-to-r from-indigo-50 to-indigo-100 p-4 pl-3 text-sm/6 font-semibold text-indigo-700 shadow-sm border border-indigo-200' :
        'group flex justify-start items-center rounded-xl p-4 pl-3 text-sm/6 font-semibold text-gray-600 hover:bg-gradient-to-r hover:from-gray-50 hover:to-gray-100 hover:text-indigo-600 transition-all duration-200 hover:shadow-md hover:scale-105'

      icon_class = is_current ?
        'size-6 shrink-0 text-indigo-600' :
        'size-6 shrink-0 text-gray-400 group-hover:text-indigo-600 transition-colors duration-200'

      link_to(edit_settings_path, class: link_class, title: 'Configuraciones', data: { tooltip: 'Configuraciones' }) do
        content_tag(:svg, class: icon_class, fill: 'none', viewBox: '0 0 24 24', "stroke-width": '2', stroke: 'currentColor') do
          content_tag(:path, nil, "stroke-linecap": 'round', "stroke-linejoin": 'round', d: 'M9.594 3.94c.09-.542.56-.94 1.11-.94h2.593c.55 0 1.02.398 1.11.94l.213 1.281c.063.374.313.686.645.87.074.04.147.083.22.127.325.196.72.257 1.075.124l1.217-.456a1.125 1.125 0 0 1 1.37.49l1.296 2.247a1.125 1.125 0 0 1-.26 1.431l-1.003.827c-.293.241-.438.613-.43.992a7.723 7.723 0 0 1 0 .255c-.008.378.137.75.43.991l1.004.827c.424.35.534.955.26 1.43l-1.298 2.247a1.125 1.125 0 0 1-1.369.491l-1.217-.456c-.355-.133-.75-.072-1.076.124a6.47 6.47 0 0 1-.22.128c-.331.183-.581.495-.644.869l-.213 1.281c-.09.543-.56.94-1.11.94h-2.594c-.55 0-1.019-.398-1.11-.94l-.213-1.281c-.062-.374-.312-.686-.644-.87a6.52 6.52 0 0 1-.22-.127c-.325-.196-.72-.257-1.076-.124l-1.217.456a1.125 1.125 0 0 1-1.369-.49l-1.297-2.247a1.125 1.125 0 0 1 .26-1.431l1.004-.827c.292-.24.437-.613.43-.991a6.932 6.932 0 0 1 0-.255c.007-.38-.138-.751-.43-.992l-1.004-.827a1.125 1.125 0 0 1-.26-1.43l1.297-2.247a1.125 1.125 0 0 1 1.37-.491l1.216.456c.356.133.751.072 1.076-.124.072-.044.146-.086.22-.128.332-.183.582-.495.644-.869l.214-1.28Z') +
          content_tag(:path, nil, "stroke-linecap": 'round', "stroke-linejoin": 'round', d: 'M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z')
        end
      end
    else
      link_class = is_current ?
        'group -mx-2 flex gap-x-3 rounded-xl bg-gradient-to-r from-indigo-50 to-indigo-100 p-3 text-sm/6 font-semibold text-indigo-700 shadow-sm border border-indigo-200 transition-all duration-200' :
        'group -mx-2 flex gap-x-3 rounded-xl p-3 text-sm/6 font-semibold text-gray-600 hover:bg-gradient-to-r hover:from-gray-50 hover:to-gray-100 hover:text-indigo-600 transition-all duration-200 hover:shadow-md hover:scale-[1.02]'

      icon_class = is_current ?
        'size-6 shrink-0 text-indigo-600' :
        'size-6 shrink-0 text-gray-400 group-hover:text-indigo-600 transition-colors duration-200'

      link_to(edit_settings_path, class: link_class) do
        svg_tag = content_tag(:svg, class: icon_class, fill: 'none', viewBox: '0 0 24 24', "stroke-width": '2', stroke: 'currentColor') do
          content_tag(:path, nil, "stroke-linecap": 'round', "stroke-linejoin": 'round', d: 'M9.594 3.94c.09-.542.56-.94 1.11-.94h2.593c.55 0 1.02.398 1.11.94l.213 1.281c.063.374.313.686.645.87.074.04.147.083.22.127.325.196.72.257 1.075.124l1.217-.456a1.125 1.125 0 0 1 1.37.49l1.296 2.247a1.125 1.125 0 0 1-.26 1.431l-1.003.827c-.293.241-.438.613-.43.992a7.723 7.723 0 0 1 0 .255c-.008.378.137.75.43.991l1.004.827c.424.35.534.955.26 1.43l-1.298 2.247a1.125 1.125 0 0 1-1.369.491l-1.217-.456c-.355-.133-.75-.072-1.076.124a6.47 6.47 0 0 1-.22.128c-.331.183-.581.495-.644.869l-.213 1.281c-.09.543-.56.94-1.11.94h-2.594c-.55 0-1.019-.398-1.11-.94l-.213-1.281c-.062-.374-.312-.686-.644-.87a6.52 6.52 0 0 1-.22-.127c-.325-.196-.72-.257-1.076-.124l-1.217.456a1.125 1.125 0 0 1-1.369-.49l-1.297-2.247a1.125 1.125 0 0 1 .26-1.431l1.004-.827c.292-.24.437-.613.43-.991a6.932 6.932 0 0 1 0-.255c.007-.38-.138-.751-.43-.992l-1.004-.827a1.125 1.125 0 0 1-.26-1.43l1.297-2.247a1.125 1.125 0 0 1 1.37-.491l1.216.456c.356.133.751.072 1.076-.124.072-.044.146-.086.22-.128.332-.183.582-.495.644-.869l.214-1.28Z') +
          content_tag(:path, nil, "stroke-linecap": 'round', "stroke-linejoin": 'round', d: 'M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z')
        end

        svg_tag + 'Configuraciones'
      end
    end
  end
end
