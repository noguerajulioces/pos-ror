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
        const unitPrice = parseFloat(item.querySelector('.item-unit-price')?.value) || 0
        const subtotal = quantity * unitPrice
        
        console.log(`Calculating: ${quantity} x ${unitPrice} = ${subtotal}`)
        
        const subtotalField = item.querySelector('.item-total-price')
        if (subtotalField) {
          subtotalField.value = subtotal.toFixed(2)
          console.log(`Updated subtotal: ${subtotal.toFixed(2)}`)
        }
        
        grandTotal += subtotal
      }
    })
    
    const totalField = document.getElementById('purchase_total_amount')
    if (totalField) {
      totalField.value = grandTotal.toFixed(2)
      console.log(`Updated grand total: ${grandTotal.toFixed(2)}`)
    }
  }
}