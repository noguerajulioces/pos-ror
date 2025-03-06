import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["option"]
  
  connect() {
    console.log("Order type controller connected")
  }
  
  selectType(event) {
    const orderType = event.currentTarget.dataset.orderType
    
    // Update the order type display in the POS view
    const orderTypeDisplay = document.getElementById("order-type-display")
    if (orderTypeDisplay) {
      orderTypeDisplay.textContent = orderType
    }
    
    // Update hidden input with order type
    const orderTypeInput = document.getElementById("selected-order-type")
    if (orderTypeInput) {
      orderTypeInput.value = orderType
    }
    
    // Save order type selection to session
    this.saveOrderTypeSelection(orderType)
    
    // Close modal
    const modalElement = document.querySelector('[data-controller~="modal"]')
    if (modalElement) {
      modalElement.remove()
    }
  }
  
  saveOrderTypeSelection(orderType) {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content
    
    fetch('/pos/set_order_type', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken
      },
      body: JSON.stringify({
        order_type: orderType
      })
    })
    .catch(error => console.error('Error saving order type selection:', error))
  }
}
