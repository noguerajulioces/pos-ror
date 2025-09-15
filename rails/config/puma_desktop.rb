# Puma configuration for POS-RoR Desktop Application
# Optimized for single-user desktop usage

# Threading configuration - optimized for desktop usage
max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 8 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { 2 }
threads min_threads_count, max_threads_count

# Port configuration - fixed port for desktop app
port ENV.fetch("PORT") { 4317 }

# Environment
environment ENV.fetch("RAILS_ENV") { "desktop" }

# Workers - single process for desktop (0 = no forking)
workers ENV.fetch("WEB_CONCURRENCY") { 0 }

# Preload app for better performance
preload_app!

# Bind to localhost only for security
bind "tcp://127.0.0.1:4317"

# Logging configuration for desktop
log_requests true
quiet false

# Restart command
restart_command 'bundle exec puma'

# Plugin configuration
plugin :tmp_restart

# Desktop-specific configuration
before_fork do
  puts "[POS-RoR Desktop] Inicializando aplicación..."
end

on_worker_boot do
  puts "[POS-RoR Desktop] Worker iniciado"
end

# Graceful shutdown
on_restart do
  puts "[POS-RoR Desktop] Reiniciando aplicación..."
end

# Desktop app specific settings
tag 'pos-ror-desktop'

# Disable daemonization for desktop usage
daemonize false

# Set process title
prune_bundler true
