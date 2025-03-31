import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("Purchase Calculator Controller Connected!")
    this.calculate()
  }

  calculate() {
    console.log("Calculating totals...")
    let grandTotal = 0
    
    // Get all nested form wrappers
    const items = document.querySelectorAll('.nested-form-wrapper')
    console.log(`Found ${items.length} items`)
    
    items.forEach((item) => {
      if (item.style.display !== 'none') { // Skip hidden items
        const quantity = parseFloat(item.querySelector('.item-quantity')?.value) || 0
        
        // Get the unit price and remove thousand separators (dots or commas)
        const unitPriceRaw = item.querySelector('.item-unit-price')?.value || '0'
        const unitPrice = parseFloat(unitPriceRaw.replace(/[.,]/g, '')) || 0
        
        const subtotal = quantity * unitPrice
        
        console.log(`Calculating: ${quantity} x ${unitPrice} = ${subtotal}`)
        
        const subtotalField = item.querySelector('.item-total-price')
        if (subtotalField) {
          // Format the subtotal with thousand separators
          const formattedSubtotal = this.formatNumber(subtotal)
          subtotalField.value = formattedSubtotal
          console.log(`Updated subtotal: ${formattedSubtotal}`)
        }
        
        grandTotal += subtotal
      }
    })
    
    const totalField = document.getElementById('purchase_total_amount')
    if (totalField) {
      // Format the grand total with thousand separators
      const formattedGrandTotal = this.formatNumber(grandTotal)
      totalField.value = formattedGrandTotal
      console.log(`Updated grand total: ${formattedGrandTotal}`)
    }
  }
  
  // Helper method to format numbers with thousand separators
  formatNumber(number) {
    return number.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ".")
  }
}