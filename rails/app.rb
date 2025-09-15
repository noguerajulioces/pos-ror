# POS-RoR Desktop - Aplicacion Rails Portable Minima
# Esta es una version ultra basica de Rails para empaquetado

require 'webrick'
require 'json'

class PosRorApp
  def self.start(port = 4317)
    puts "[POS-RoR] Iniciando aplicacion Rails portable en puerto #{port}"

    server = WEBrick::HTTPServer.new(
      Port: port,
      DocumentRoot: File.join(__dir__, 'public'),
      Logger: WEBrick::Log.new(nil, WEBrick::Log::ERROR),
      AccessLog: []
    )

    # Ruta de salud para Tauri
    server.mount_proc '/up' do |req, res|
      res.body = JSON.generate({
        status: 'ok',
        app: 'POS-RoR Desktop',
        version: '1.0.0',
        timestamp: Time.now.iso8601
      })
      res['Content-Type'] = 'application/json'
    end

    # Ruta principal
    server.mount_proc '/' do |req, res|
      html = <<~HTML
        <!DOCTYPE html>
        <html lang="es">
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>POS-RoR Desktop</title>
          <style>
            body {#{' '}
              font-family: Arial, sans-serif;#{' '}
              margin: 0;#{' '}
              padding: 40px;#{' '}
              background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
              color: white;#{' '}
              min-height: 100vh;#{' '}
              display: flex;#{' '}
              align-items: center;#{' '}
              justify-content: center;#{' '}
            }
            .container {#{' '}
              text-align: center;#{' '}
              background: rgba(255,255,255,0.1);#{' '}
              padding: 60px;#{' '}
              border-radius: 20px;#{' '}
              backdrop-filter: blur(10px);#{' '}
            }
            h1 { font-size: 3em; margin-bottom: 20px; }
            .status {#{' '}
              background: rgba(76, 175, 80, 0.2);#{' '}
              border: 1px solid rgba(76, 175, 80, 0.5);#{' '}
              border-radius: 10px;#{' '}
              padding: 15px;#{' '}
              margin: 20px 0;#{' '}
            }
          </style>
        </head>
        <body>
          <div class="container">
            <h1>🏪 POS-RoR Desktop</h1>
            <p>Sistema de Punto de Venta - Versión Portable</p>
            <div class="status">
              ✅ Aplicación Rails funcionando correctamente
            </div>
            <p>Puerto: #{port}<br>
               Timestamp: #{Time.now}<br>
               Ruby: #{RUBY_VERSION}</p>
          </div>
        </body>
        </html>
      HTML

      res.body = html
      res['Content-Type'] = 'text/html; charset=utf-8'
    end

    trap('INT') { server.shutdown }
    trap('TERM') { server.shutdown }

    puts "[POS-RoR] Servidor iniciado en http://localhost:#{port}"
    puts "[POS-RoR] Presiona Ctrl+C para detener"

    server.start
  rescue => e
    puts "[POS-RoR] Error: #{e.message}"
    exit 1
  end
end

# Iniciar si se ejecuta directamente
if __FILE__ == $0
  port = ARGV[0]&.to_i || 4317
  PosRorApp.start(port)
end
