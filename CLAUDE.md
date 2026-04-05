# POS App — Guía para Claude

## Stack
- Ruby on Rails (ERB), Tailwind CSS
- Sin librerías de UI externas — solo clases utilitarias de Tailwind
- Hotwire (Turbo + Stimulus)

---

## Design System

### Layout de páginas
- Fondo: `bg-gray-50 min-h-screen`
- Contenedor show/detail: `max-w-5xl mx-auto px-4 sm:px-6 py-6 space-y-5`
- Contenedor index/listado: `px-4 sm:px-6 lg:px-8`

### Cards
```
bg-white border border-gray-200 rounded-lg overflow-hidden
```
- Header: `px-5 py-3 border-b border-gray-100`
- Título del card: `text-sm font-semibold text-gray-700`
- Cuerpo: `px-5 py-4`
- Sin `shadow` pesados ni gradientes (`bg-gradient-to-r` no usar)
- Sin iconos decorativos en headers de cards

### Tipografía
| Rol | Clases |
|-----|--------|
| Título de página | `text-xl font-semibold text-gray-900` |
| Subtítulo / meta | `text-sm text-gray-500` |
| Label de campo (dl) | `text-sm text-gray-500` |
| Valor de campo (dl) | `text-sm font-medium text-gray-900` |
| Texto secundario | `text-xs text-gray-400` |

### Grids responsivos
```
grid grid-cols-1 lg:grid-cols-2 gap-5
```

---

## Botones

### Acción con texto + icono (headers de página)
```erb
<%= link_to path, class: "inline-flex items-center gap-1.5 px-3 py-1.5 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50" do %>
  <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">...</svg>
  Texto
<% end %>
```
Variante destructiva:
```
text-red-600 border-red-300 hover:bg-red-50
```

### Solo icono + tooltip (columna Acciones en tablas)
```erb
<%= link_to path, title: "Tooltip", class: "inline-flex items-center rounded-md bg-white px-2.5 py-1.5 text-xs font-semibold text-gray-700 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50" do %>
  <svg class="h-3.5 w-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">...</svg>
<% end %>
```
Variante destructiva:
```
text-red-600 ring-red-200 hover:bg-red-50
```

### Regla: ¿texto o solo icono?
- **Texto + icono**: botones en el header de una página (Imprimir, Editar, Cancelar, Volver)
- **Solo icono**: columna Acciones dentro de tablas (Ver, Imprimir, Cancelar fila)

---

## Tablas

```html
<table class="min-w-full text-sm">
  <thead>
    <tr class="text-xs text-gray-500 uppercase tracking-wide border-b border-gray-100">
      <th class="px-5 py-2 text-left font-medium">Columna</th>
    </tr>
  </thead>
  <tbody class="divide-y divide-gray-100">
    <tr class="text-gray-700 hover:bg-gray-50 transition-colors duration-100">
      <td class="px-5 py-3">...</td>
    </tr>
  </tbody>
</table>
```

---

## Badges de estado

```erb
<span class="text-xs font-medium px-2 py-0.5 rounded-full <%= color %>">Texto</span>
```

| Estado | Color |
|--------|-------|
| Completado | `bg-green-100 text-green-700` |
| Cuenta abierta / En espera | `bg-yellow-100 text-yellow-700` |
| Cancelado / Error | `bg-red-100 text-red-700` |
| Pago pendiente / Advertencia | `bg-orange-100 text-orange-700` |
| En tienda / Neutro | `bg-blue-100 text-blue-700` |
| Delivery | `bg-orange-100 text-orange-700` |

---

## Progress bar

```html
<div class="w-full bg-gray-100 rounded-full h-1.5">
  <div class="bg-indigo-500 h-1.5 rounded-full" style="width: <%= percent %>%"></div>
</div>
```
- Completo (100%): `bg-green-500`
- En progreso: `bg-indigo-500`

---

## Colores de acento
| Uso | Color |
|-----|-------|
| Acción principal | `indigo-600` |
| Éxito / completado | `green-600` |
| Destructivo | `red-600` |
| Advertencia | `orange-500` |
| Info | `blue-600` |

---

## Flash / Alertas

```erb
<div class="bg-green-50 border border-green-200 text-green-700 px-4 py-3 rounded text-sm">
  <%= notice %>
</div>
```

---

## Reglas generales
- No usar gradientes (`bg-gradient-to-r`)
- No usar `shadow-lg` — preferir `border border-gray-200`
- No agregar iconos decorativos en títulos de secciones
- Confirmar acciones destructivas con `data: { turbo_confirm: "..." }`
- Botones con `flex-wrap gap-2` para que no se rompan en móvil
- Idioma de la UI: **español**
