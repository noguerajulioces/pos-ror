// POS-RoR Desktop - Version ULTRA BASICA para distribucion

#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

fn main() {
    println!("Iniciando POS-RoR Desktop...");
    
    tauri::Builder::default()
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}