import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["stockField", "costField"]

  connect() {
    // Verificar estado inicial
    this.toggleCostField()
  }

  toggleCostField() {
    const stockValue = parseFloat(this.stockFieldTarget.value) || 0
    
    if (stockValue > 0) {
      this.costFieldTarget.style.display = "block"
    } else {
      this.costFieldTarget.style.display = "none"
      // Limpiar el valor del costo si no hay stock
      const costInput = this.costFieldTarget.querySelector('input[name*="average_cost"]')
      if (costInput) {
        costInput.value = ""
      }
    }
  }
}
