# ============================================================================
# POS-RoR Desktop - Application Configuration Override
# ============================================================================
# Configuraciones específicas para el modo desktop que sobrescriben
# las configuraciones base de la aplicación Rails

# Cargar configuración base de Rails
require_relative 'application'

# Configuraciones específicas para desktop
Rails.application.configure do
  # Desktop mode flag
  config.desktop_mode = true

  # Asset serving - debe servir assets estáticos
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    'Cache-Control' => 'public, max-age=31536000'
  }

  # Logging específico para desktop
  if ENV['RAILS_LOG_TO_STDOUT'].blank?
    log_path = File.join(ENV['APPDATA'] || '.', 'POS-RoR-Desktop', 'logs')
    FileUtils.mkdir_p(log_path) unless File.exist?(log_path)
    config.logger = ActiveSupport::Logger.new(File.join(log_path, 'application.log'), 'daily')
    config.logger.level = Logger::INFO
  end

  # Cache store para desktop (usar directorio del usuario)
  cache_path = File.join(ENV['APPDATA'] || '.', 'POS-RoR-Desktop', 'cache')
  config.cache_store = :file_store, cache_path

  # Active Storage para desktop
  storage_path = File.join(ENV['APPDATA'] || '.', 'POS-RoR-Desktop', 'storage')
  config.active_storage.variant_processor = :mini_magick

  # Job queue - usar async para evitar dependencias externas
  config.active_job.queue_adapter = :async

  # Mailer configuration para desktop
  config.action_mailer.delivery_method = :file
  config.action_mailer.file_settings = {
    location: File.join(ENV['APPDATA'] || '.', 'POS-RoR-Desktop', 'mail')
  }
  config.action_mailer.default_url_options = { host: 'localhost', port: 4317 }

  # Disable some features not needed in desktop
  config.force_ssl = false
  config.assume_ssl = false

  # Allow all hosts for desktop (runs on localhost)
  config.hosts.clear
  config.host_authorization = { exclude: ->(request) { true } }

  # CORS settings para desktop
  config.web_console.permissions = '127.0.0.1'

  # Timezone para desktop (usar timezone del sistema)
  config.time_zone = 'America/Mexico_City'  # Cambiar según tu zona

  # I18n configuration
  config.i18n.default_locale = :es
  config.i18n.available_locales = [ :es, :en ]
  config.i18n.fallbacks = true

  # Desktop specific middleware
  config.middleware.insert_before ActionDispatch::Static, Proc.new { |env|
    # Add desktop-specific headers
    [ 200, { 'X-Desktop-Mode' => 'true' }, [] ]
  } if ENV['RAILS_ENV'] == 'desktop'
end

# Desktop-specific initializers
if Rails.application.config.desktop_mode
  # Ensure required directories exist
  required_dirs = %w[db logs cache storage mail].map do |dir|
    File.join(ENV['APPDATA'] || '.', 'POS-RoR-Desktop', dir)
  end

  required_dirs.each do |dir|
    FileUtils.mkdir_p(dir) unless File.exist?(dir)
  end

  # Desktop-specific database configuration
  if ENV['DATABASE_URL'].blank?
    db_path = File.join(ENV['APPDATA'] || '.', 'POS-RoR-Desktop', 'db', 'production.sqlite3')
    ENV['DATABASE_URL'] = "sqlite3://#{db_path}"
  end
end
