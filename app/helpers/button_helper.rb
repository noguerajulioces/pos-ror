module ButtonHelper
  def role_button(text, path, options = {})
    return '' unless can_access_path?(path, options[:action])

    default_classes = 'rounded-md px-3 py-2 text-sm font-semibold shadow-sm focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2'

    case options[:style]
    when :primary
      classes = "#{default_classes} bg-indigo-600 text-white hover:bg-indigo-500 focus-visible:outline-indigo-600"
    when :danger
      classes = "#{default_classes} bg-red-600 text-white hover:bg-red-500 focus-visible:outline-red-600"
    when :success
      classes = "#{default_classes} bg-green-600 text-white hover:bg-green-500 focus-visible:outline-green-600"
    else
      classes = "#{default_classes} bg-white text-gray-900 ring-1 ring-inset ring-gray-300 hover:bg-gray-50"
    end

    link_to text, path, class: classes, **options.except(:style, :action)
  end

  def role_form_button(text, options = {})
    return '' unless can_access_path?(options[:url], options[:action])

    default_classes = 'rounded-md px-3 py-2 text-sm font-semibold shadow-sm focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2'

    case options[:style]
    when :primary
      classes = "#{default_classes} bg-indigo-600 text-white hover:bg-indigo-500 focus-visible:outline-indigo-600"
    when :danger
      classes = "#{default_classes} bg-red-600 text-white hover:bg-red-500 focus-visible:outline-red-600"
    when :success
      classes = "#{default_classes} bg-green-600 text-white hover:bg-green-500 focus-visible:outline-green-600"
    else
      classes = "#{default_classes} bg-white text-gray-900 ring-1 ring-inset ring-gray-300 hover:bg-gray-50"
    end

    button_tag text, class: classes, **options.except(:style, :action, :url)
  end

  private

  def can_access_path?(path, action = nil)
    return true if path.nil?

    # Extraer el controlador y acción de la ruta
    if path.is_a?(String)
      # Para rutas como '/users' o '/orders'
      controller_name = path.gsub('/', '').pluralize
    elsif path.is_a?(Hash)
      # Para rutas como { controller: 'users', action: 'index' }
      controller_name = path[:controller] || 'users'
      action = path[:action] || 'index'
    else
      # Para objetos como user_path(@user)
      controller_name = path.to_s.split('/').reject(&:empty?).first&.pluralize || 'users'
    end

    # Verificar permisos basados en el controlador y acción
    case controller_name
    when 'users'
      can?(:manage, User)
    when 'orders'
      case action
      when 'create'
        can?(:create, Order)
      when 'destroy'
        can?(:destroy, Order)
      else
        can?(:read, Order)
      end
    when 'products', 'simple_products', 'recipes', 'combos'
      can?(:manage, :products)
    when 'cash_registers'
      can?(:read, :cash_registers)
    when 'reports'
      can?(:read, :reports)
    when 'settings'
      can?(:manage, :settings)
    when 'customers'
      can?(:read, Customer)
    when 'suppliers'
      can?(:manage, :suppliers)
    when 'categories', 'ingredients', 'units', 'currencies', 'payment_methods'
      can?(:manage, controller_name.classify.constantize)
    when 'expenses', 'purchases', 'stocks'
      can?(:manage, controller_name.classify.constantize)
    when 'pos'
      can?(:read, :pos)
    else
      true
    end
  end
end
