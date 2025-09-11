import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="recipe-summary"
export default class extends Controller {
  static targets = ["details"]

  toggleDetails() {
    this.detailsTarget.classList.toggle('hidden')
    
    const button = this.element.querySelector('[data-action="click->recipe-summary#toggleDetails"]')
    if (this.detailsTarget.classList.contains('hidden')) {
      button.textContent = 'Ver Detalles'
    } else {
      button.textContent = 'Ocultar Detalles'
    }
  }

  simulateProduction() {
    // Esta función simula la producción mostrando qué pasaría con el stock
    const productId = this.element.dataset.productId
    
    if (confirm('¿Deseas simular la producción de 1 unidad de este producto?')) {
      // Aquí podrías hacer una llamada AJAX para simular la producción
      // Por ahora, solo mostramos una alerta
      this.showProductionSimulation()
    }
  }

  showProductionSimulation() {
    // Crear modal de simulación
    const modal = document.createElement('div')
    modal.className = 'fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity z-50'
    modal.innerHTML = `
      <div class="fixed inset-0 z-10 w-screen overflow-y-auto">
        <div class="flex min-h-full items-end justify-center p-4 text-center sm:items-center sm:p-0">
          <div class="relative transform overflow-hidden rounded-lg bg-white px-4 pb-4 pt-5 text-left shadow-xl transition-all sm:my-8 sm:w-full sm:max-w-lg sm:p-6">
            <div class="flex items-center justify-between border-b border-gray-200 pb-4 mb-4">
              <h3 class="text-lg font-semibold text-gray-900">Simulación de Producción</h3>
              <button type="button" onclick="this.closest('.fixed').remove()" class="text-gray-400 hover:text-gray-600">
                <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </div>
            
            <div class="mb-4">
              <p class="text-sm text-gray-600 mb-4">
                Al producir 1 unidad de este producto, se deducirían los siguientes ingredientes:
              </p>
              
              <div class="bg-yellow-50 border border-yellow-200 rounded-lg p-4">
                <div class="text-sm text-yellow-800">
                  <strong>⚠️ Nota:</strong> Esta es una simulación. No se realizarán cambios reales en el stock.
                </div>
              </div>
            </div>
            
            <div class="flex items-center justify-end space-x-3 pt-4 border-t border-gray-200">
              <button type="button" 
                      onclick="this.closest('.fixed').remove()"
                      class="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50">
                Cerrar
              </button>
            </div>
          </div>
        </div>
      </div>
    `
    
    document.body.appendChild(modal)
    
    // Auto-remove after 10 seconds
    setTimeout(() => {
      if (modal.parentNode) {
        modal.remove()
      }
    }, 10000)
  }
}
