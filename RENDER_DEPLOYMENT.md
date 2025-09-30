# Guía de Deploy en Render

## Master Key generada

Tu `RAILS_MASTER_KEY` es:
```
6a12ab073cecae093c2c585d264945c3
```

**⚠️ IMPORTANTE:** Guarda esta key en un lugar seguro (como un password manager). Si la pierdes, no podrás acceder a las credenciales encriptadas.

## Pasos para Deploy en Render

### 1. Crear cuenta en Render
- Ve a [https://render.com](https://render.com)
- Crea una cuenta (puedes usar GitHub)

### 2. Conectar repositorio
1. Click en "New +"
2. Selecciona "Web Service"
3. Conecta tu repositorio de GitHub/GitLab
4. O usa "Public Git repository" con tu URL

### 3. Configurar el servicio

#### Configuración básica:
- **Name:** `pos-ror` (o el nombre que prefieras)
- **Runtime:** Ruby
- **Build Command:** `./bin/render-build.sh`
- **Start Command:** `bundle exec puma -C config/puma.rb`

#### Variables de entorno:
Agrega estas variables en la sección "Environment":

1. **RAILS_MASTER_KEY**
   ```
   6a12ab073cecae093c2c585d264945c3
   ```

2. **RAILS_ENV**
   ```
   production
   ```

3. **RAILS_LOG_TO_STDOUT**
   ```
   enabled
   ```

4. **RAILS_SERVE_STATIC_FILES**
   ```
   enabled
   ```

5. **DATABASE_URL** (se configurará automáticamente con la base de datos)

### 4. Crear base de datos PostgreSQL

1. En el dashboard de Render, click en "New +"
2. Selecciona "PostgreSQL"
3. Configuración:
   - **Name:** `pos-ror-db`
   - **Database:** `pos_ror_production`
   - **User:** `pos_ror`
   - **Plan:** Free (o el que prefieras)

4. Una vez creada, copia la **Internal Database URL**

5. Vuelve a tu Web Service y agrega la variable:
   - **DATABASE_URL:** (pega la URL de la base de datos)

### 5. Configurar secretos adicionales (opcional)

Si necesitas configurar otros secretos (API keys, etc.):

```bash
# En tu máquina local
EDITOR="code --wait" rails credentials:edit
```

Agrega tus secretos:
```yaml
secret_key_base: <%= ENV["SECRET_KEY_BASE"] %>
stripe:
  api_key: tu_stripe_key
aws:
  access_key_id: tu_aws_key
```

### 6. Deploy automático

Render tiene las siguientes configuraciones en `render.yaml`:

```yaml
services:
  - type: web
    name: pos-ror
    runtime: ruby
    plan: free
    buildCommand: "./bin/render-build.sh"
    startCommand: "bundle exec puma -C config/puma.rb"
    envVars:
      - key: RAILS_MASTER_KEY
        sync: false
```

### 7. Hacer deploy

1. Commit y push los cambios:
   ```bash
   git add .
   git commit -m "Add Render configuration"
   git push origin main
   ```

2. En Render:
   - Click en "Manual Deploy" → "Deploy latest commit"
   - O espera el auto-deploy si está habilitado

### 8. Ejecutar seeds (primera vez)

Después del primer deploy exitoso:

1. En Render, ve a tu Web Service
2. Click en "Shell" en el menú lateral
3. Ejecuta:
   ```bash
   rails db:seed
   ```

### 9. Verificar el deploy

- URL de tu app: `https://tu-app.onrender.com`
- Health check: `https://tu-app.onrender.com/up`

## Troubleshooting

### Error: "Missing encryption key to decrypt file with"
**Solución:** Verifica que `RAILS_MASTER_KEY` esté correctamente configurada en las variables de entorno.

### Error: "Database does not exist"
**Solución:** Las migraciones se ejecutan automáticamente en `bin/render-build.sh`.

### Error: "Assets not precompiled"
**Solución:** Verifica que `RAILS_SERVE_STATIC_FILES=enabled` esté configurado.

### App muy lenta en plan Free
**Solución:** Render Free duerme las apps después de 15 min de inactividad. Considera upgradearte a un plan pago.

## Comandos útiles en Render Shell

```bash
# Ver logs
rails log:tail

# Ejecutar migraciones
rails db:migrate

# Ejecutar seeds
rails db:seed

# Acceder a consola Rails
rails console

# Ver versión de Ruby
ruby -v

# Ver versión de Rails
rails -v
```

## Configuración de dominio personalizado

1. En Render, ve a tu Web Service
2. Click en "Settings"
3. En "Custom Domain", agrega tu dominio
4. Configura los DNS records en tu proveedor de dominio:
   ```
   CNAME: tu-dominio.com → tu-app.onrender.com
   ```

## Monitoreo

### Health Check endpoint
La app incluye un health check en:
```
GET /up
```

Respuesta exitosa:
```json
{
  "status": "ok",
  "timestamp": "2024-09-30T12:00:00Z"
}
```

### Logs
Ver logs en tiempo real:
1. Dashboard de Render → Tu servicio → "Logs"
2. O usa Render Shell: `rails log:tail`

## Backup de base de datos

### Crear backup manual
1. Dashboard de Render → Tu base de datos → "Backups"
2. Click en "Create Backup"

### Restaurar backup
1. Dashboard de Render → Tu base de datos → "Backups"
2. Selecciona el backup → "Restore"

## Costos (Plan Free)

- **Web Service Free:** $0/mes
  - 750 horas/mes
  - Duerme después de 15 min de inactividad
  - 512 MB RAM

- **PostgreSQL Free:** $0/mes
  - 90 días de retención
  - 1 GB de almacenamiento
  - Expira después de 90 días

## Upgrade a plan pago

Si necesitas más recursos:

1. **Starter Plan:** $7/mes
   - Sin sleep
   - 512 MB RAM
   - SSL incluido

2. **Standard Plan:** $25/mes
   - 2 GB RAM
   - Mayor CPU
   - Mejor performance

## Variables de entorno recomendadas adicionales

```bash
# Para mejor performance
WEB_CONCURRENCY=2
RAILS_MAX_THREADS=5

# Para ActionMailer
SMTP_ADDRESS=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=tu_email@gmail.com
SMTP_PASSWORD=tu_app_password
SMTP_DOMAIN=gmail.com

# Para ActiveStorage (si usas AWS S3)
AWS_ACCESS_KEY_ID=tu_aws_key
AWS_SECRET_ACCESS_KEY=tu_aws_secret
AWS_REGION=us-east-1
AWS_BUCKET=tu_bucket
```

## Checklist de Deploy

- [ ] Master key guardada en lugar seguro
- [ ] `render.yaml` configurado
- [ ] `bin/render-build.sh` con permisos de ejecución
- [ ] Variables de entorno configuradas en Render
- [ ] Base de datos PostgreSQL creada
- [ ] DATABASE_URL configurada
- [ ] Código pusheado a GitHub/GitLab
- [ ] Deploy manual ejecutado
- [ ] Seeds ejecutados (primera vez)
- [ ] Health check funcionando (`/up`)
- [ ] Login funcionando
- [ ] Roles y permisos verificados

## Soporte

- Documentación oficial: [https://render.com/docs](https://render.com/docs)
- Community forum: [https://community.render.com](https://community.render.com)
- Status page: [https://status.render.com](https://status.render.com)
