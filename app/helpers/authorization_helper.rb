module AuthorizationHelper
  def role_based_content(&block)
    if block_given?
      capture(&block)
    end
  end

  def show_for_role(role_name, &block)
    if current_user&.has_role?(role_name) && block_given?
      capture(&block)
    end
  end

  def hide_for_role(role_name, &block)
    unless current_user&.has_role?(role_name)
      capture(&block) if block_given?
    end
  end

  def role_badge(role_name)
    case role_name.to_s
    when 'superadmin'
      content_tag :span, 'Super Admin', class: 'inline-flex items-center rounded-full bg-purple-100 px-2.5 py-0.5 text-xs font-medium text-purple-800'
    when 'vendedor'
      content_tag :span, 'Vendedor', class: 'inline-flex items-center rounded-full bg-green-100 px-2.5 py-0.5 text-xs font-medium text-green-800'
    when 'cajero'
      content_tag :span, 'Cajero', class: 'inline-flex items-center rounded-full bg-blue-100 px-2.5 py-0.5 text-xs font-medium text-blue-800'
    else
      content_tag :span, role_name.to_s.humanize, class: 'inline-flex items-center rounded-full bg-gray-100 px-2.5 py-0.5 text-xs font-medium text-gray-800'
    end
  end

  def current_user_roles
    current_user&.roles&.map(&:name) || []
  end

  def has_any_role?(*roles)
    roles.any? { |role| current_user&.has_role?(role) }
  end
end
