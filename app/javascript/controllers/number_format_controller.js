import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="number-format"
export default class extends Controller {
  static targets = ["input"]

  connect() {
    this.inputTarget.addEventListener('input', this.formatNumber.bind(this))
    // Limpiar formato antes de enviar el formulario
    this.element.closest('form').addEventListener('submit', this.cleanForSubmit.bind(this))
  }

  formatNumber(e) {
    let value = e.target.value
    
    // Store cursor position
    const cursorPosition = e.target.selectionStart
    const oldValue = e.target.value
    
    // Allow only digits (no decimals for Guaraníes)
    value = value.replace(/\D/g, '')
    
    // Don't format if empty
    if (value === '') {
      e.target.value = ''
      return
    }
    
    // Add thousand separators (dots)
    const formattedValue = value.replace(/\B(?=(\d{3})+(?!\d))/g, ".")
    
    // Only update if the value actually changed (to avoid infinite loops)
    if (formattedValue !== oldValue) {
      e.target.value = formattedValue
      
      // Restore cursor position approximately
      const dotsAdded = (formattedValue.match(/\./g) || []).length - (oldValue.match(/\./g) || []).length
      const newCursorPosition = Math.min(cursorPosition + dotsAdded, formattedValue.length)
      e.target.setSelectionRange(newCursorPosition, newCursorPosition)
    }
  }

  cleanForSubmit(e) {
    // Eliminar los puntos del formato antes de enviar
    const rawValue = this.inputTarget.value.replace(/\./g, '')
    this.inputTarget.value = rawValue
  }
}
