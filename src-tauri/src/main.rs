// ============================================================================
// POS-RoR Desktop - Main Tauri Application
// ============================================================================
// Esta aplicación de escritorio inicia Rails con Ruby portable y abre
// un WebView apuntando a localhost:4317

#![cfg_attr(
    all(not(debug_assertions), target_os = "windows"),
    windows_subsystem = "windows"
)]

use std::process::{Command, Stdio};
use std::thread;
use std::time::Duration;
use tauri::{Manager, State};
use std::sync::{Arc, Mutex};

// Estado global para el proceso de Rails
#[derive(Default)]
struct AppState {
    rails_process: Arc<Mutex<Option<std::process::Child>>>,
}

// Función para verificar si Rails está respondiendo
async fn check_rails_health() -> bool {
    match reqwest::get("http://127.0.0.1:4317/up").await {
        Ok(response) => response.status().is_success(),
        Err(_) => false,
    }
}

// Función para iniciar Rails
async fn start_rails_server(app_handle: tauri::AppHandle, state: State<'_, AppState>) -> Result<(), String> {
    println!("[POS-RoR] Iniciando servidor Rails...");
    
    // Obtener el directorio de recursos de la aplicación
    let resource_dir = app_handle
        .path()
        .resource_dir()
        .map_err(|e| format!("Error obteniendo directorio de recursos: {}", e))?;
    
    let rails_dir = resource_dir.join("rails");
    let start_script = rails_dir.join("bin").join("start-rails.bat");
    
    println!("[POS-RoR] Directorio Rails: {:?}", rails_dir);
    println!("[POS-RoR] Script de inicio: {:?}", start_script);
    
    // Verificar que el script existe
    if !start_script.exists() {
        return Err(format!("Script de inicio no encontrado: {:?}", start_script));
    }
    
    // Iniciar el proceso Rails
    let mut child = Command::new("cmd")
        .args(["/C", start_script.to_str().unwrap()])
        .current_dir(&rails_dir)
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn()
        .map_err(|e| format!("Error iniciando Rails: {}", e))?;
    
    println!("[POS-RoR] Proceso Rails iniciado con PID: {}", child.id());
    
    // Guardar el proceso en el estado global
    {
        let mut process = state.rails_process.lock().unwrap();
        *process = Some(child);
    }
    
    // Esperar a que Rails esté listo (máximo 60 segundos)
    println!("[POS-RoR] Esperando a que Rails esté listo...");
    for attempt in 1..=60 {
        if check_rails_health().await {
            println!("[POS-RoR] Rails está listo después de {} segundos", attempt);
            return Ok(());
        }
        
        // Verificar si el proceso sigue corriendo
        {
            let mut process = state.rails_process.lock().unwrap();
            if let Some(ref mut child) = *process {
                match child.try_wait() {
                    Ok(Some(status)) => {
                        return Err(format!("Rails terminó inesperadamente con código: {:?}", status));
                    }
                    Ok(None) => {
                        // Proceso sigue corriendo, continuar esperando
                    }
                    Err(e) => {
                        return Err(format!("Error verificando estado de Rails: {}", e));
                    }
                }
            }
        }
        
        thread::sleep(Duration::from_secs(1));
        
        if attempt % 10 == 0 {
            println!("[POS-RoR] Esperando Rails... intento {}/60", attempt);
        }
    }
    
    Err("Timeout esperando a que Rails esté listo".to_string())
}

// Función para detener Rails
fn stop_rails_server(state: State<AppState>) {
    println!("[POS-RoR] Deteniendo servidor Rails...");
    
    let mut process = state.rails_process.lock().unwrap();
    if let Some(mut child) = process.take() {
        // Intentar terminar el proceso graciosamente
        match child.kill() {
            Ok(_) => println!("[POS-RoR] Proceso Rails terminado"),
            Err(e) => println!("[POS-RoR] Error terminando Rails: {}", e),
        }
        
        // Esperar a que el proceso termine
        match child.wait() {
            Ok(status) => println!("[POS-RoR] Rails terminó con estado: {:?}", status),
            Err(e) => println!("[POS-RoR] Error esperando terminación: {}", e),
        }
    }
}

// Comandos Tauri
#[tauri::command]
async fn get_rails_status() -> Result<String, String> {
    if check_rails_health().await {
        Ok("running".to_string())
    } else {
        Err("Rails no está respondiendo".to_string())
    }
}

#[tauri::command]
async fn restart_rails(app_handle: tauri::AppHandle, state: State<'_, AppState>) -> Result<String, String> {
    println!("[POS-RoR] Reiniciando Rails...");
    
    // Detener Rails actual
    stop_rails_server(state.clone());
    
    // Esperar un momento
    thread::sleep(Duration::from_secs(2));
    
    // Iniciar Rails nuevamente
    start_rails_server(app_handle, state).await?;
    
    Ok("Rails reiniciado exitosamente".to_string())
}

fn main() {
    tauri::Builder::default()
        .manage(AppState::default())
        .plugin(tauri_plugin_shell::init())
        .plugin(tauri_plugin_dialog::init())
        .plugin(tauri_plugin_fs::init())
        .plugin(tauri_plugin_path::init())
        .plugin(tauri_plugin_os::init())
        .plugin(tauri_plugin_process::init())
        .invoke_handler(tauri::generate_handler![
            get_rails_status,
            restart_rails
        ])
        .setup(|app| {
            let app_handle = app.handle().clone();
            let state = app.state::<AppState>();
            
            // Iniciar Rails en un hilo separado
            let app_handle_clone = app_handle.clone();
            let state_clone = state.inner().clone();
            
            tauri::async_runtime::spawn(async move {
                match start_rails_server(app_handle_clone, State::from(&*state_clone)).await {
                    Ok(_) => {
                        println!("[POS-RoR] Rails iniciado exitosamente");
                        
                        // Mostrar la ventana principal una vez que Rails esté listo
                        if let Some(window) = app_handle_clone.get_webview_window("main") {
                            window.show().unwrap();
                            window.set_focus().unwrap();
                        }
                    }
                    Err(e) => {
                        println!("[POS-RoR] Error iniciando Rails: {}", e);
                        
                        // Mostrar diálogo de error
                        let _ = tauri_plugin_dialog::MessageDialogBuilder::new(
                            "Error de Inicio",
                            format!("No se pudo iniciar el servidor Rails:\n\n{}", e)
                        )
                        .kind(tauri_plugin_dialog::MessageDialogKind::Error)
                        .show();
                        
                        // Cerrar la aplicación
                        std::process::exit(1);
                    }
                }
            });
            
            Ok(())
        })
        .on_window_event(|window, event| {
            match event {
                tauri::WindowEvent::CloseRequested { .. } => {
                    println!("[POS-RoR] Cerrando aplicación...");
                    
                    // Detener Rails antes de cerrar
                    let state = window.state::<AppState>();
                    stop_rails_server(state);
                    
                    // Dar tiempo para que Rails se cierre
                    thread::sleep(Duration::from_secs(1));
                }
                _ => {}
            }
        })
        .run(tauri::generate_context!())
        .expect("Error ejecutando aplicación Tauri");
}
