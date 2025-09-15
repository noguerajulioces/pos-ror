// ============================================================================
// POS-RoR Desktop - Main Tauri Application (Simplified)
// ============================================================================

#![cfg_attr(
    all(not(debug_assertions), target_os = "windows"),
    windows_subsystem = "windows"
)]

use std::process::{Command, Stdio};
use std::thread;
use std::time::Duration;

// Función simple para verificar si Rails está respondiendo
async fn check_rails_health() -> bool {
    match reqwest::get("http://127.0.0.1:4317/up").await {
        Ok(response) => response.status().is_success(),
        Err(_) => false,
    }
}

// Función para iniciar Rails (versión simplificada)
fn start_rails_server() -> Result<std::process::Child, String> {
    println!("[POS-RoR] Iniciando servidor Rails...");
    
    // Para testing, intentar iniciar Rails desde el directorio actual
    let rails_script = if cfg!(target_os = "windows") {
        "rails\\bin\\start-rails.bat"
    } else {
        "rails/bin/start-rails.bat"
    };
    
    println!("[POS-RoR] Script de inicio: {}", rails_script);
    
    let mut child = Command::new("cmd")
        .args(["/C", rails_script])
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn()
        .map_err(|e| format!("Error iniciando Rails: {}", e))?;
    
    println!("[POS-RoR] Proceso Rails iniciado con PID: {}", child.id());
    Ok(child)
}

#[tokio::main]
async fn main() {
    println!("[POS-RoR] Iniciando POS-RoR Desktop...");
    
    // Intentar iniciar Rails (no crítico para el build)
    let _rails_process = match start_rails_server() {
        Ok(process) => {
            println!("[POS-RoR] Rails iniciado exitosamente");
            
            // Esperar un poco a que Rails esté listo
            println!("[POS-RoR] Esperando a que Rails esté listo...");
            for i in 1..=10 {
                if check_rails_health().await {
                    println!("[POS-RoR] Rails está listo después de {} segundos", i);
                    break;
                }
                thread::sleep(Duration::from_secs(1));
                
                if i == 10 {
                    println!("[POS-RoR] Rails no respondió, continuando de todos modos...");
                }
            }
            
            Some(process)
        }
        Err(e) => {
            println!("[POS-RoR] No se pudo iniciar Rails: {}", e);
            println!("[POS-RoR] Continuando sin Rails (solo para testing)...");
            None
        }
    };
    
    // Iniciar aplicación Tauri
    tauri::Builder::default()
        .setup(|app| {
            println!("[POS-RoR] Tauri setup completado");
            
            // Mostrar ventana principal
            if let Some(window) = app.get_webview_window("main") {
                let _ = window.show();
            }
            
            Ok(())
        })
        .run(tauri::generate_context!())
        .expect("Error ejecutando aplicación Tauri");
}