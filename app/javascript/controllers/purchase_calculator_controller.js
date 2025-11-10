import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["quantity", "unitPrice", "subtotal", "totalAmount"]

  connect() {
    // Initialize timeout variable
    this.calculationTimeout = null
    
    // Format existing values on page load
    this.formatExistingValues()
    
    // Calculate total after formatting
    this.calculateTotal()
    
    // Listen for when rows are added or removed
    this.element.addEventListener('rails-nested-form:add', (event) => {
      setTimeout(() => {
        // Find all rows with data-new-record="true" and get the last one (most recently added)
        const newRows = this.element.querySelectorAll('.nested-form-wrapper[data-new-record="true"]')
        if (newRows.length > 0) {
          const newRow = newRows[newRows.length - 1]
          this.formatNewRow(newRow)
          this.calculateTotal()
        }
      }, 100)
    })
    
    this.element.addEventListener('rails-nested-form:remove', () => {
      setTimeout(() => this.calculateTotal(), 100)
    })
  }

  disconnect() {
    // Clean up timeout when controller is disconnected
    if (this.calculationTimeout) {
      clearTimeout(this.calculationTimeout)
      this.calculationTimeout = null
    }
  }

  // Helper function to parse formatted numbers (integers only for Guaraníes)
  parseFormattedNumber(value) {
    if (!value) return 0
    
    let cleanValue = value.toString().trim()
    
    // If it's empty or just dots, return 0
    if (cleanValue === '' || cleanValue.replace(/\./g, '') === '') {
      return 0
    }
    
    // For Guaraníes, we only have thousand separators (dots), no decimals
    // Simply remove all dots and parse as integer
    cleanValue = cleanValue.replace(/\./g, '')
    
    // Handle edge cases where user might be in the middle of editing
    if (cleanValue === '') {
      return 0
    }
    
    const result = parseInt(cleanValue) || 0
    
    // Debug log for troubleshooting (remove in production)
    console.log(`parseFormattedNumber: "${value}" -> "${cleanValue}" -> ${result}`)
    
    return result
  }

  calculateSubtotal(event) {
    // Clear any existing timeout
    if (this.calculationTimeout) {
      clearTimeout(this.calculationTimeout)
    }
    
    // Add a small delay to avoid calculations while user is actively typing
    this.calculationTimeout = setTimeout(() => {
      const row = event.target.closest('[data-purchase-calculator-target="row"]')
      const quantity = parseFloat(row.querySelector('[data-purchase-calculator-target="quantity"]').value) || 0
      const unitPriceValue = row.querySelector('[data-purchase-calculator-target="unitPrice"]').value
      const unitPrice = this.parseFormattedNumber(unitPriceValue)
      const subtotal = quantity * unitPrice
      
      console.log(`Calculation: ${quantity} × ${unitPrice} = ${subtotal}`)
      
      // Format subtotal with thousand separators
      row.querySelector('[data-purchase-calculator-target="subtotal"]').value = this.formatNumber(subtotal)
      
      this.calculateTotal()
    }, 300) // 300ms delay
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