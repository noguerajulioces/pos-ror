import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["quantity", "unitPrice", "subtotal", "totalAmount"]

  connect() {
    this.calculateAll()
    
    // Listen for when rows are added or removed
    this.element.addEventListener('nested-form:added', () => {
      setTimeout(() => this.calculateAll(), 100)
    })
    
    this.element.addEventListener('nested-form:removed', () => {
      setTimeout(() => this.calculateTotal(), 100)
    })
  }

  // Helper function to parse formatted numbers (integers only for Guaraníes)
  parseFormattedNumber(value) {
    if (!value) return 0
    // Remove thousand separators (dots) and parse as integer
    return parseInt(value.toString().replace(/\./g, '')) || 0
  }

  calculateSubtotal(event) {
    const row = event.target.closest('[data-purchase-calculator-target="row"]')
    const quantity = parseFloat(row.querySelector('[data-purchase-calculator-target="quantity"]').value) || 0
    const unitPriceValue = row.querySelector('[data-purchase-calculator-target="unitPrice"]').value
    const unitPrice = this.parseFormattedNumber(unitPriceValue)
    const subtotal = quantity * unitPrice
    
    // Format subtotal with thousand separators
    row.querySelector('[data-purchase-calculator-target="subtotal"]').value = this.formatNumber(subtotal)
    
    this.calculateTotal()
  }

  // Helper function to format integers with thousand separators (for Guaraníes)
  formatNumber(number) {
    // Round to integer (no decimals for Guaraníes)
    let integerValue = Math.round(number).toString()
    
    // Add thousand separators (dots)
    return integerValue.replace(/\B(?=(\d{3})+(?!\d))/g, ".")
  }

  calculateTotal() {
    let total = 0
    this.subtotalTargets.forEach(subtotal => {
      // Parse formatted subtotal values
      total += this.parseFormattedNumber(subtotal.value)
    })
    
    if (this.hasTotalAmountTarget) {
      // Format total with thousand separators
      this.totalAmountTarget.value = this.formatNumber(total)
    }
  }

  calculateAll() {
    this.quantityTargets.forEach((quantity, index) => {
      const row = quantity.closest('[data-purchase-calculator-target="row"]')
      const unitPriceValue = row.querySelector('[data-purchase-calculator-target="unitPrice"]').value
      const unitPrice = this.parseFormattedNumber(unitPriceValue)
      const qty = parseFloat(quantity.value) || 0
      const subtotal = qty * unitPrice
      
      // Format subtotal with thousand separators
      row.querySelector('[data-purchase-calculator-target="subtotal"]').value = this.formatNumber(subtotal)
    })
    
    this.calculateTotal()
  }
}