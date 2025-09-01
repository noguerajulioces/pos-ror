import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["quantity", "unitPrice", "subtotal", "totalAmount"]

  connect() {
    this.calculateAll()
  }

  calculateSubtotal(event) {
    const row = event.target.closest('[data-purchase-calculator-target="row"]')
    const quantity = parseFloat(row.querySelector('[data-purchase-calculator-target="quantity"]').value) || 0
    const unitPrice = parseFloat(row.querySelector('[data-purchase-calculator-target="unitPrice"]').value) || 0
    const subtotal = quantity * unitPrice
    
    row.querySelector('[data-purchase-calculator-target="subtotal"]').value = subtotal.toFixed(2)
    
    this.calculateTotal()
  }

  calculateTotal() {
    let total = 0
    this.subtotalTargets.forEach(subtotal => {
      total += parseFloat(subtotal.value) || 0
    })
    
    if (this.hasTotalAmountTarget) {
      this.totalAmountTarget.value = total.toFixed(2)
    }
  }

  calculateAll() {
    this.quantityTargets.forEach((quantity, index) => {
      const row = quantity.closest('[data-purchase-calculator-target="row"]')
      const unitPrice = parseFloat(row.querySelector('[data-purchase-calculator-target="unitPrice"]').value) || 0
      const qty = parseFloat(quantity.value) || 0
      const subtotal = qty * unitPrice
      
      row.querySelector('[data-purchase-calculator-target="subtotal"]').value = subtotal.toFixed(2)
    })
    
    this.calculateTotal()
  }
}