import { Controller } from "@hotwired/stimulus"
import RailsNestedForm from "@stimulus-components/rails-nested-form"

export default class extends RailsNestedForm {
  connect() {
    super.connect()
    this.calculateTotals()
  }

  calculateTotals() {
    let grandTotal = 0
    
    this.element.querySelectorAll('.nested-fields').forEach((item) => {
      const quantity = parseFloat(item.querySelector('.item-quantity').value) || 0
      const unitPrice = parseFloat(item.querySelector('.item-unit-price').value) || 0
      const totalPrice = quantity * unitPrice
      
      item.querySelector('.item-total-price').value = totalPrice.toFixed(2)
      grandTotal += totalPrice
    })
    
    document.getElementById('purchase_total_amount').value = grandTotal.toFixed(2)
  }

  itemAdded(event) {
    super.itemAdded(event)
    this.calculateTotals()
  }

  itemRemoved(event) {
    super.itemRemoved(event)
    this.calculateTotals()
  }
}