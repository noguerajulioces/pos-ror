#!/usr/bin/env ruby
# POS-RoR Desktop - Script de inicio portable

# Agregar directorio actual al load path
$LOAD_PATH.unshift(__dir__)

puts "[POS-RoR] Iniciando POS-RoR Desktop Portable..."
puts "[POS-RoR] Ruby version: #{RUBY_VERSION}"
puts "[POS-RoR] Platform: #{RUBY_PLATFORM}"

# Cargar aplicación
require_relative 'app'

# Iniciar en puerto 4317 (default para Tauri)
port = ENV['PORT']&.to_i || 4317
PosRorApp.start(port)
