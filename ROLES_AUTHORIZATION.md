# Sistema de Autorización por Roles

## Roles disponibles

### 1. Superadmin
- Acceso total al sistema
- Gestión de usuarios y roles
- Configuración del sistema
- Todos los reportes y estadísticas

### 2. Vendedor
- Acceso al POS
- Crear órdenes
- Ver productos
- Ver clientes
- NO puede gestionar usuarios, productos, ni configuración

### 3. Cajero
- Acceso al POS
- Ver órdenes
- Gestionar caja (abrir/cerrar)
- Ver reportes
- NO puede crear órdenes ni gestionar productos

## Uso en Controladores

### Los controladores ya tienen autorización automática con:

```ruby
load_and_authorize_resource  # Ya implementado en OrdersController y ProductsController
```

### Para agregar autorización a un nuevo controlador:

```ruby
class MiControlador < ApplicationController
  load_and_authorize_resource  # Esto es todo lo que necesitas
end
```

## Uso en Vistas

### Verificar permisos con can?

```erb
<% if can? :create, Order %>
  <%= link_to 'Nueva Orden', new_order_path %>
<% end %>

<% if can? :manage, User %>
  <%= link_to 'Gestionar Usuarios', users_path %>
<% end %>

<% if can? :read, :reports %>
  <%= link_to 'Reportes', reports_path %>
<% end %>
```

### Helpers disponibles

```erb
<!-- Mostrar contenido solo para un rol específico -->
<%= show_for_role(:superadmin) do %>
  <p>Solo superadmins ven esto</p>
<% end %>

<!-- Ocultar contenido para un rol específico -->
<%= hide_for_role(:vendedor) do %>
  <p>Los vendedores no ven esto</p>
<% end %>

<!-- Mostrar badge de rol -->
<%= role_badge(:superadmin) %>
<%= role_badge(:vendedor) %>
<%= role_badge(:cajero) %>

<!-- Verificar si tiene algún rol -->
<% if has_any_role?(:superadmin, :cajero) %>
  <p>Es superadmin o cajero</p>
<% end %>
```

## Personalizar permisos

### Editar el archivo `app/models/ability.rb`

```ruby
class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    if user.has_role?(:superadmin)
      can :manage, :all  # Acceso total
    end

    if user.has_role?(:vendedor)
      can [:read, :create], Order
      can :read, Product
      cannot :destroy, Order  # Explícitamente denegar
    end

    if user.has_role?(:cajero)
      can :read, Order
      can [:open, :close], CashRegister
      can :read, Product
    end
  end
end
```

## Asignar roles a usuarios

### Desde la vista de usuario (solo superadmins)

1. Ir a `/users`
2. Clic en "Ver" en un usuario
3. Marcar/desmarcar roles en la sección "Gestión de Roles"
4. Clic en "Actualizar Roles"

### Desde la consola Rails

```ruby
user = User.find_by(email: 'usuario@ejemplo.com')

# Agregar rol
user.add_role :vendedor
user.add_role :cajero

# Remover rol
user.remove_role :vendedor

# Verificar si tiene un rol
user.has_role? :superadmin  # => true/false

# Ver todos los roles
user.roles.map(&:name)  # => ["superadmin", "vendedor"]
```

## Mensajes de error

Si un usuario intenta acceder a una sección sin permisos:
- Se redirige a la página anterior
- Se muestra un mensaje: "No tienes permisos para acceder a esta sección."

## Controladores que ya tienen autorización

- `OrdersController` → `load_and_authorize_resource`
- `ProductsController` → `load_and_authorize_resource`
- `CashRegistersController` → Autorización manual para `open` y `close`

## Agregar nuevos roles

1. Crear el rol en seeds o consola:
```ruby
Role.create(name: 'nuevo_rol')
```

2. Agregar permisos en `app/models/ability.rb`:
```ruby
if user.has_role?(:nuevo_rol)
  can :read, SomeModel
  can :create, SomeModel
end
```

3. Actualizar el helper `role_badge` si quieres un badge personalizado:
```ruby
# En app/helpers/authorization_helper.rb
when 'nuevo_rol'
  content_tag :span, 'Nuevo Rol', class: 'badge badge-warning'
```

## Debugging

### Ver roles de usuario actual
```erb
<%= current_user.roles.map(&:name).join(', ') %>
```

### Verificar permisos en consola
```ruby
user = User.first
ability = Ability.new(user)

ability.can?(:read, Order)    # => true/false
ability.can?(:manage, User)   # => true/false
ability.can?(:create, Product) # => true/false
```

## Mejores prácticas

1. **Usar `load_and_authorize_resource` en controladores**: Es automático y cubre todos los casos.
2. **Verificar permisos en vistas con `can?`**: Oculta botones y enlaces que el usuario no puede usar.
3. **Mantener permisos en `Ability`**: Toda la lógica de autorización en un solo lugar.
4. **Usar helpers**: `show_for_role`, `role_badge`, etc. para código más limpio.
5. **Probar permisos**: Crear usuarios de prueba con diferentes roles para verificar.

## Ejemplo completo

```ruby
# app/controllers/productos_controller.rb
class ProductosController < ApplicationController
  load_and_authorize_resource  # ← Esto autoriza automáticamente
  
  def index
    # @productos ya está cargado y autorizado
  end
  
  def create
    # El usuario debe tener permiso :create en Producto
    # Si no lo tiene, se lanza CanCan::AccessDenied
  end
end
```

```erb
<!-- app/views/productos/index.html.erb -->
<h1>Productos</h1>

<% if can? :create, Producto %>
  <%= link_to 'Nuevo Producto', new_producto_path, class: 'btn btn-primary' %>
<% end %>

<table>
  <% @productos.each do |producto| %>
    <tr>
      <td><%= producto.nombre %></td>
      <td>
        <%= link_to 'Ver', producto_path(producto) if can? :read, producto %>
        <%= link_to 'Editar', edit_producto_path(producto) if can? :update, producto %>
        <%= link_to 'Eliminar', producto_path(producto), method: :delete if can? :destroy, producto %>
      </td>
    </tr>
  <% end %>
</table>
```
