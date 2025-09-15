// POS-RoR Desktop - Version ULTRA SIMPLE para generar MSI

#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

fn main() {
    println!("[POS-RoR] Iniciando POS-RoR Desktop (version ultra simple)");
    
    tauri::Builder::default()
        .setup(|app| {
            println!("[POS-RoR] Tauri setup completado");
            
            // Mostrar ventana principal
            if let Some(window) = app.get_webview_window("main") {
                let _ = window.show();
                let _ = window.set_focus();
            }
            
            Ok(())
        })
        .run(tauri::generate_context!())
        .expect("Error ejecutando Tauri");
}