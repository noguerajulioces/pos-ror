module SidebarHelper
  def sidebar_items
    items = []

    # POS - Accesible para todos los roles
    if can?(:read, :pos)
      items << {
        name: 'POS',
        path: pos_path,
        icon: 'shopping-cart',
        active: current_page?(pos_path)
      }
    end

    # Órdenes - Accesible para vendedores y cajeros
    if can?(:read, Order)
      items << {
        name: 'Órdenes',
        path: orders_path,
        icon: 'receipt',
        active: current_page?(orders_path)
      }
    end

    # Productos - Solo para superadmin
    if can?(:manage, :products)
      items << {
        name: 'Productos',
        path: products_path,
        icon: 'box',
        active: current_page?(products_path)
      }
    end

    # Caja - Solo para cajeros y superadmin
    if can?(:read, :cash_registers)
      items << {
        name: 'Caja',
        path: cash_registers_path,
        icon: 'currency-dollar',
        active: current_page?(cash_registers_path)
      }
    end

    # Clientes - Accesible para vendedores y cajeros
    if can?(:read, Customer)
      items << {
        name: 'Clientes',
        path: customers_path,
        icon: 'users',
        active: current_page?(customers_path)
      }
    end

    # Reportes - Solo para cajeros y superadmin
    if can?(:read, :reports)
      items << {
        name: 'Reportes',
        path: reports_path,
        icon: 'chart-bar',
        active: current_page?(reports_path)
      }
    end

    # Usuarios - Solo para superadmin
    if can?(:manage, User)
      items << {
        name: 'Usuarios',
        path: users_path,
        icon: 'user-group',
        active: current_page?(users_path)
      }
    end

    # Configuración - Solo para superadmin
    if can?(:manage, :settings)
      items << {
        name: 'Configuración',
        path: edit_settings_path,
        icon: 'cog',
        active: current_page?(edit_settings_path)
      }
    end

    items
  end

  def render_sidebar
    content_tag :nav, class: 'bg-gray-800 text-white w-64 min-h-screen' do
      content_tag :div, class: 'p-4' do
        content_tag :h2, 'POS System', class: 'text-xl font-bold mb-6' +
          sidebar_items.map do |item|
            link_to item[:path], class: "flex items-center p-3 rounded-lg mb-2 #{item[:active] ? 'bg-indigo-600' : 'hover:bg-gray-700'}" do
              content_tag(:i, '', class: "fas fa-#{item[:icon]} mr-3") + item[:name]
            end
          end.join.html_safe
      end
    end
  end
end
