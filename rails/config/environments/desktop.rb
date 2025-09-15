# Desktop environment configuration for POS-RoR
# Optimized for single-user desktop deployment with SQLite

require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Desktop app should be considered as production-like but with some development conveniences
  config.cache_classes = true
  config.eager_load = true

  # Show full error reports in desktop mode for easier debugging
  config.consider_all_requests_local = false

  # Caching configuration for desktop
  config.action_controller.perform_caching = true

  # Use file store for caching in desktop mode
  config.cache_store = :file_store, File.join(ENV['APPDATA'] || '.', 'POS-RoR-Desktop', 'cache')

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this. But enable for desktop app.
  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present? || true

  # Compress CSS using a preprocessor.
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = true
  config.assets.digest = true

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for Apache
  # config.action_dispatch.x_sendfile_header = "X-Accel-Redirect" # for NGINX

  # Store uploaded files locally for desktop app
  config.active_storage.variant_processor = :mini_magick

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # Disabled for desktop app running on localhost
  config.force_ssl = false

  # Log to STDOUT by default, but allow file logging for desktop
  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  else
    # Log to files in user's AppData directory
    log_path = File.join(ENV['APPDATA'] || '.', 'POS-RoR-Desktop', 'logs', 'application.log')
    config.logger = ActiveSupport::Logger.new(log_path, 'daily')
  end

  # Set log level
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Prepend all log lines with the following tags.
  config.log_tags = [ :request_id ]

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Use a real queuing backend for Active Job (and separate queues per environment).
  # For desktop app, use async adapter to avoid external dependencies
  config.active_job.queue_adapter = :async
  # config.active_job.queue_name_prefix = "pos_ror_production"

  # Disable caching for Action Mailer templates even if Action Controller caching is enabled.
  config.action_mailer.perform_caching = false

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options = { host: 'localhost:4317' }

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Don't log any deprecations for desktop app
  config.active_support.report_deprecations = false

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Use a different logger for distributed setups.
  # require "syslog/logger"
  # config.logger = ActiveSupport::TaggedLogging.new(Syslog::Logger.new "app-name")

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  # Do not dump schema after migrations for desktop app
  config.active_record.dump_schema_after_migration = false

  # Enable DNS rebinding protection and other `Host` header attacks.
  # config.hosts = [
  #   "example.com",     # Allow requests from example.com
  #   /.*\.example\.com/ # Allow requests from subdomains like `www.example.com`
  # ]
  # Skip DNS rebinding protection for desktop app
  config.hosts.clear

  # Desktop-specific configurations
  config.desktop_mode = true

  # Disable some production features not needed for desktop
  config.force_ssl = false

  # Allow all origins for desktop app (since it runs on localhost)
  config.web_console.allowed_ips = [ '127.0.0.1', '::1' ]
end
