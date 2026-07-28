# POS

Sistema de punto de venta multi-tenant construido con Ruby on Rails 8 y Hotwire.

Este repositorio aloja **dos productos distintos en dos ramas separadas**. No es un flujo
`feature branch → main`: cada rama es la línea de desarrollo de un cliente diferente y ambas
son de larga duración.

---

## Ramas

| Rama | Cliente | Rubro | Estado |
|------|---------|-------|--------|
| `main` | Ferretería | Venta de productos de ferretería | Rama por defecto en GitHub |
| `principal` | KombiBurguer | Gastronomía / hamburguesería | Rama de desarrollo activo |

Ambas ramas divergieron en el commit `d3e965c` (29 de julio de 2025) y desde entonces
evolucionan por separado.

### `main` — Ferretería

Versión orientada a venta de mostrador de productos físicos:

- Catálogo de productos, variantes, categorías y stock
- Clientes (`clients_controller`), proveedores y compras
- Caja, órdenes y reportes
- Multi-tenant con `acts_as_tenant`

### `principal` — KombiBurguer

Versión gastronómica. Contiene lo mismo que `main` más lo específico del rubro:

- **Mesas** (`Table`) y flujo de cuentas abiertas por mesa
- **Delivery** y órdenes pendientes
- **Recetas e ingredientes** (`Recipe`, `Ingredient`, `RecipeComponent`) con descuento de stock por insumo
- **Combos** (`Combo`, `ComboItem`)
- **Modificadores** de producto (`Modifier`, `ModifierGroup`) — extras, quitar ingredientes, etc.
- **Transferencias de stock** entre sucursales (`StockTransfer`, `IngredientTransfer`)
- **Roles y permisos** con `rolify` + `cancancan` (ver [ROLES_AUTHORIZATION.md](ROLES_AUTHORIZATION.md))
- Impuestos (`TaxRate`) y monitoreo de errores con Sentry

### Cómo trabajar con las ramas

```bash
# Trabajar en Ferretería
git checkout main

# Trabajar en KombiBurguer
git checkout principal
```

**Reglas importantes:**

- Nunca mergear `principal` → `main` completo: arrastraría funcionalidad gastronómica
  (mesas, recetas, combos) que la ferretería no usa.
- Los arreglos que aplican a ambos productos (bugs de núcleo, seguridad, dependencias)
  se llevan con `git cherry-pick` de una rama a la otra.
- Los PRs deben apuntar explícitamente a la rama del cliente correspondiente. GitHub
  propone `main` por defecto — verificar antes de abrir el PR si el trabajo es de KombiBurguer.

---

## Stack

- **Ruby** 3.4.1 · **Rails** 8.0
- **PostgreSQL**
- **Hotwire** (Turbo + Stimulus) con `importmap-rails` — sin bundler de JS
- **Tailwind CSS** vía `tailwindcss-rails` — sin librerías de UI externas
- **Solid Queue / Solid Cache / Solid Cable** (respaldados por la base de datos)
- **Devise** (autenticación), **Pundit** + **CanCanCan** (autorización), **acts_as_tenant** (multi-tenancy)
- **wicked_pdf** (comprobantes PDF), **escpos** / **barby** / **rqrcode** (impresión térmica y códigos)

Las convenciones de UI y el design system están en [CLAUDE.md](CLAUDE.md).

---

## Puesta en marcha

### Requisitos

- Ruby 3.4.1
- PostgreSQL
- ImageMagick (para `image_processing` / `mini_magick`)
- `wkhtmltopdf` (se instala vía gem en desarrollo)

### Instalación

```bash
git clone <repo>
cd pos-ror
git checkout principal        # o main, según el cliente

bin/setup                     # instala gems, prepara la base y arranca el servidor
```

O paso a paso:

```bash
bundle install
bin/rails db:prepare
bin/rails db:seed             # roles, monedas, cuenta demo y datos de ejemplo
bin/dev                       # servidor + watcher de Tailwind (usa foreman)
```

La app queda en http://localhost:3000

### Con Docker

```bash
export RAILS_MASTER_KEY=$(cat config/master.key)
docker compose up
```

Levanta PostgreSQL 15 y la app en el puerto 3000.

---

## Comandos habituales

```bash
bin/dev                       # desarrollo (web + tailwind:watch)
bin/rails test                # suite de tests
bin/rails test:system         # tests de sistema (Capybara + Selenium)
bin/rubocop                   # linter (rubocop-rails-omakase)
bin/brakeman                  # análisis estático de seguridad
bin/rails db:seed             # datos de ejemplo
bin/rails annotaterb:models   # anota esquemas en los modelos
bin/rails erd                 # diagrama entidad-relación
```

---

## Deploy

Ambas ramas se despliegan en [Render](https://render.com) usando `render.yaml` y
`bin/render-build.sh` (bundle install → precompile assets → migrate).

Instrucciones detalladas en [RENDER_DEPLOYMENT.md](RENDER_DEPLOYMENT.md).

> **Nota de seguridad:** `RENDER_DEPLOYMENT.md` tiene la `RAILS_MASTER_KEY` en texto plano
> dentro del repositorio. Conviene rotar la key y mover el valor a un gestor de secretos.

---

## Documentación adicional

| Documento | Contenido |
|-----------|-----------|
| [CLAUDE.md](CLAUDE.md) | Design system, convenciones de UI y reglas de estilo |
| [ROLES_AUTHORIZATION.md](ROLES_AUTHORIZATION.md) | Roles disponibles y uso de la autorización |
| [RENDER_DEPLOYMENT.md](RENDER_DEPLOYMENT.md) | Guía de deploy paso a paso |
