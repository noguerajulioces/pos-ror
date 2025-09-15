// POS-RoR Desktop - Aplicacion Tauri con Ruby Portable

#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

use std::process::{Command, Stdio};
use std::thread;
use std::time::Duration;

// Funcion para verificar si Rails esta respondiendo
async fn check_rails_health() -> bool {
    match reqwest::get("http://127.0.0.1:4317/up").await {
        Ok(response) => response.status().is_success(),
        Err(_) => false,
    }
}

// Funcion para iniciar Rails portable
fn start_rails_portable() -> Result<std::process::Child, String> {
    println!("[POS-RoR] Iniciando Rails portable...");
    
    // Obtener directorio de recursos
    let resource_dir = std::env::current_exe()
        .map_err(|e| format!("Error obteniendo exe path: {}", e))?
        .parent()
        .ok_or("No parent directory")?
        .join("rails");
    
    let start_script = resource_dir.join("start.bat");
    
    println!("[POS-RoR] Script: {:?}", start_script);
    println!("[POS-RoR] Rails dir: {:?}", resource_dir);
    
    // Verificar que el script existe
    if !start_script.exists() {
        return Err(format!("Script no encontrado: {:?}", start_script));
    }
    
    // Iniciar proceso
    let child = Command::new("cmd")
        .args(["/C", start_script.to_str().unwrap()])
        .current_dir(&resource_dir)
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn()
        .map_err(|e| format!("Error iniciando Rails: {}", e))?;
    
    println!("[POS-RoR] Rails iniciado con PID: {}", child.id());
    Ok(child)
}

#[tokio::main]
async fn main() {
    println!("[POS-RoR] Iniciando POS-RoR Desktop...");
    
    // Intentar iniciar Rails portable
    let _rails_process = match start_rails_portable() {
        Ok(process) => {
            println!("[POS-RoR] Rails portable iniciado");
            
            // Esperar a que Rails este listo
            println!("[POS-RoR] Esperando Rails...");
            for i in 1..=30 {
                if check_rails_health().await {
                    println!("[POS-RoR] Rails listo en {} segundos", i);
                    break;
                }
                thread::sleep(Duration::from_secs(1));
                
                if i == 30 {
                    println!("[POS-RoR] Timeout esperando Rails");
                }
            }
            
            Some(process)
        }
        Err(e) => {
            println!("[POS-RoR] No se pudo iniciar Rails: {}", e);
            println!("[POS-RoR] Continuando solo con frontend...");
            None
        }
    };
    
    // Iniciar Tauri
    tauri::Builder::default()
        .setup(|app| {
            println!("[POS-RoR] Tauri setup completado");
            
            // Mostrar ventana
            if let Some(window) = app.get_webview_window("main") {
                let _ = window.show();
                let _ = window.set_focus();
            }
            
            Ok(())
        })
        .run(tauri::generate_context!())
        .expect("Error ejecutando Tauri");
}