import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["quantity", "unitPrice", "subtotal", "totalAmount"]

  connect() {
    // Format existing values on page load
    this.formatExistingValues()
    
    // Calculate total after formatting
    this.calculateTotal()
    
    // Listen for when rows are added or removed
    this.element.addEventListener('nested-form:added', (event) => {
      setTimeout(() => {
        // Only format the new row, not existing ones
        this.formatNewRow(event.detail.target)
        this.calculateTotal()
      }, 100)
    })
    
    this.element.addEventListener('nested-form:removed', () => {
      setTimeout(() => this.calculateTotal(), 100)
    })
  }

  // Helper function to parse formatted numbers (integers only for Guaraníes)
  parseFormattedNumber(value) {
    if (!value) return 0
    
    let cleanValue = value.toString().trim()
    
    // Remove any decimal part (for values like 23000.0)
    if (cleanValue.includes('.')) {
      // Check if it's a decimal number (like 23000.0) or thousand separator (like 23.000)
      let parts = cleanValue.split('.')
      if (parts.length === 2 && parts[1].length <= 2 && parseInt(parts[1]) === 0) {
        // It's a decimal like 23000.0, take only the integer part
        cleanValue = parts[0]
      } else {
        // It's thousand separators like 23.000, remove all dots
        cleanValue = cleanValue.replace(/\./g, '')
      }
    }
    
    return parseInt(cleanValue) || 0
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

  // Format existing values on page load (for edit mode)
  formatExistingValues() {
    // Format unit prices
    this.unitPriceTargets.forEach(unitPrice => {
      if (unitPrice.value && unitPrice.value.trim() !== '') {
        const numericValue = this.parseFormattedNumber(unitPrice.value)
        unitPrice.value = this.formatNumber(numericValue)
      }
    })
    
    // Format subtotals
    this.subtotalTargets.forEach(subtotal => {
      if (subtotal.value && subtotal.value.trim() !== '') {
        const numericValue = this.parseFormattedNumber(subtotal.value)
        subtotal.value = this.formatNumber(numericValue)
      }
    })
    
    // Format total amount
    if (this.hasTotalAmountTarget && this.totalAmountTarget.value && this.totalAmountTarget.value.trim() !== '') {
      const numericValue = this.parseFormattedNumber(this.totalAmountTarget.value)
      this.totalAmountTarget.value = this.formatNumber(numericValue)
    }
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

  // Format only a new row (used when adding new items)
  formatNewRow(row) {
    const quantityElement = row.querySelector('[data-purchase-calculator-target="quantity"]')
    const unitPriceElement = row.querySelector('[data-purchase-calculator-target="unitPrice"]')
    const subtotalElement = row.querySelector('[data-purchase-calculator-target="subtotal"]')
    
    if (quantityElement && unitPriceElement && subtotalElement) {
      const quantity = parseFloat(quantityElement.value) || 0
      const unitPrice = this.parseFormattedNumber(unitPriceElement.value)
      const subtotal = quantity * unitPrice
      
      // Format subtotal for new row
      subtotalElement.value = this.formatNumber(subtotal)
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