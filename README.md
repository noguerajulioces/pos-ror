# POS Ferretería

Punto de venta multi-tenant para venta de mostrador, construido con Ruby on Rails 8 y Hotwire.

> **KombiBurguer se mudó**
> Este repositorio alojaba dos productos en dos ramas: `main` (Ferretería) y `principal`
> (KombiBurguer). En julio de 2026 KombiBurguer se separó a su propio repositorio,
> [`noguerajulioces/kombiburguer`](https://github.com/noguerajulioces/kombiburguer) (privado),
> con la historia completa.
>
> La rama `principal` sigue acá como respaldo del momento del corte, pero **está retirada**:
> el desarrollo gastronómico continúa en el repo nuevo. No abras PRs contra `principal`.

---

## Funcionalidad

- Catálogo de productos con variantes, categorías, subcategorías e imágenes
- Stock y movimientos de inventario
- Punto de venta, órdenes y pagos (múltiples métodos y monedas)
- Caja: apertura, cierre y movimientos
- Clientes, proveedores, compras y gastos
- Reportes
- Impresión de comprobantes en PDF y generación de códigos de barra / QR
- **Multi-tenant** con `acts_as_tenant`: cada `Account` tiene sus datos aislados

---

## Stack

- **Ruby** 3.4.1 · **Rails** 8.0
- **PostgreSQL**
- **Hotwire** (Turbo + Stimulus) con `importmap-rails` — sin bundler de JS
- **Tailwind CSS** vía `tailwindcss-rails` — sin librerías de UI externas
- **Solid Queue / Solid Cache / Solid Cable** (respaldados por la base de datos)
- **Devise** (autenticación) y **acts_as_tenant** (multi-tenancy)
- **wicked_pdf** (comprobantes), **barby** / **rqrcode** / **chunky_png** (códigos)
- **ransack** (búsquedas), **will_paginate**, **friendly_id**, **paranoia** (borrado lógico)

La UI está en español y usa solo clases utilitarias de Tailwind, sin librerías de componentes.

---

## Puesta en marcha

### Requisitos

- Ruby 3.4.1
- PostgreSQL
- ImageMagick (para `image_processing` / `mini_magick`)
- `wkhtmltopdf` (se instala vía gem)

### Instalación

```bash
git clone git@github.com:noguerajulioces/pos-ror.git
cd pos-ror

bin/setup                     # instala gems, prepara la base y arranca el servidor
```

O paso a paso:

```bash
bundle install
bin/rails db:prepare
bin/rails db:seed             # cuenta demo, usuario, monedas y datos de ejemplo
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
bin/rubocop                   # linter (rubocop-rails-omakase)
bin/brakeman                  # análisis estático de seguridad
bin/rails db:seed             # datos de ejemplo
bin/rails annotaterb:models   # anota esquemas en los modelos
bin/rails erd                 # diagrama entidad-relación
```

---

## Deploy

El repo trae `Dockerfile`, `docker-compose.yml` y la configuración de
[Kamal](https://kamal-deploy.org) en `config/deploy.yml`.

**Kamal está sin configurar**: `config/deploy.yml` conserva los valores de la plantilla
(`image: your-user/pos_ror`, servidor `192.168.0.1`). Antes de desplegar hay que completar
imagen, servidores, registry y secretos en `.kamal/secrets`.

> **⚠️ Credencial expuesta**
> Este repositorio es **público** y la rama `principal` contiene un `RENDER_DEPLOYMENT.md`
> con la `RAILS_MASTER_KEY` en texto plano. Esa key desencripta `config/credentials.yml.enc`,
> que está commiteado. **Hay que rotarla** — borrar el archivo no alcanza, el valor sigue en
> el historial de git de este repo y del repo de KombiBurguer.
