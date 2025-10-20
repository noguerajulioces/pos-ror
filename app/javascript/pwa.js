// PWA Service Worker Registration
if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('/service-worker')
      .then((registration) => {
        console.log('Service Worker registered successfully:', registration.scope);
        
        // Verificar actualizaciones
        registration.addEventListener('updatefound', () => {
          const newWorker = registration.installing;
          newWorker.addEventListener('statechange', () => {
            if (newWorker.state === 'installed' && navigator.serviceWorker.controller) {
              // Nueva versión disponible
              console.log('Nueva versión de la app disponible');
              if (confirm('Hay una nueva versión disponible. ¿Deseas actualizar?')) {
                window.location.reload();
              }
            }
          });
        });
      })
      .catch((error) => {
        console.log('Service Worker registration failed:', error);
      });
  });
}

// PWA Install Prompt
let deferredPrompt;
const installButton = document.createElement('button');
installButton.textContent = '📱 Instalar App';
installButton.className = 'fixed bottom-4 right-4 bg-indigo-600 text-white px-4 py-2 rounded-lg shadow-lg hover:bg-indigo-700 transition-colors z-50 hidden';
installButton.id = 'install-button';

// Agregar botón al DOM
document.addEventListener('DOMContentLoaded', () => {
  document.body.appendChild(installButton);
});

// Escuchar evento beforeinstallprompt
window.addEventListener('beforeinstallprompt', (e) => {
  console.log('PWA install prompt available');
  e.preventDefault();
  deferredPrompt = e;
  
  // Mostrar botón de instalación
  installButton.classList.remove('hidden');
  
  installButton.addEventListener('click', async () => {
    if (deferredPrompt) {
      deferredPrompt.prompt();
      const { outcome } = await deferredPrompt.userChoice;
      console.log(`User response to the install prompt: ${outcome}`);
      
      if (outcome === 'accepted') {
        console.log('User accepted the install prompt');
        installButton.classList.add('hidden');
      }
      
      deferredPrompt = null;
    }
  });
});

// Detectar cuando la app se instala
window.addEventListener('appinstalled', (e) => {
  console.log('PWA was installed');
  installButton.classList.add('hidden');
  
  // Opcional: mostrar mensaje de bienvenida
  setTimeout(() => {
    if (confirm('¡App instalada correctamente! ¿Deseas abrir el POS?')) {
      window.location.href = '/pos';
    }
  }, 1000);
});

// Detectar si la app se está ejecutando como PWA
function isPWA() {
  return window.matchMedia('(display-mode: standalone)').matches || 
         window.navigator.standalone === true;
}

// Agregar clase CSS si es PWA
if (isPWA()) {
  document.documentElement.classList.add('pwa-mode');
  console.log('Running as PWA');
}

// Manejo de conexión offline/online
window.addEventListener('online', () => {
  console.log('Connection restored');
  // Opcional: mostrar notificación de conexión restaurada
  showConnectionStatus('Conexión restaurada', 'success');
});

window.addEventListener('offline', () => {
  console.log('Connection lost');
  // Opcional: mostrar notificación de conexión perdida
  showConnectionStatus('Sin conexión - Modo offline', 'warning');
});

// Función para mostrar estado de conexión
function showConnectionStatus(message, type) {
  const notification = document.createElement('div');
  notification.className = `fixed top-4 right-4 px-4 py-2 rounded-lg shadow-lg z-50 transition-all duration-300 ${
    type === 'success' ? 'bg-green-500 text-white' : 'bg-yellow-500 text-black'
  }`;
  notification.textContent = message;
  
  document.body.appendChild(notification);
  
  setTimeout(() => {
    notification.style.opacity = '0';
    setTimeout(() => {
      document.body.removeChild(notification);
    }, 300);
  }, 3000);
}

export { isPWA, showConnectionStatus };
