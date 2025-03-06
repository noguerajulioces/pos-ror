import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["option"]
  
  connect() {
    console.log("Order type controller connected")
  }
  
  selectType(event) {
    event.preventDefault()
    const orderType = event.currentTarget.dataset.orderType
    console.log("Selected order type:", orderType)
    
    // Update the order type display in the POS view
    const orderTypeDisplay = document.getElementById("order-type-display")
    if (orderTypeDisplay) {
      orderTypeDisplay.textContent = orderType
    } else {
      console.error("Could not find order-type-display element")
    }
    
    // Update hidden input with order type
    const orderTypeInput = document.getElementById("selected-order-type")
    if (orderTypeInput) {
      orderTypeInput.value = orderType
    } else {
      console.error("Could not find selected-order-type element")
    }
    
    // Save order type selection to session
    this.saveOrderTypeSelection(orderType)
    
    // Find the modal element
    const modalElement = event.currentTarget.closest('[data-controller~="modal"]')
    if (modalElement) {
      // Close the modal
      console.log("Closing modal")
      modalElement.remove()
    } else {
      console.error("Could not find modal element")
      // Try alternative method to find modal
      const alternativeModal = document.getElementById("modal")
      if (alternativeModal) {
        alternativeModal.remove()
      }
    }
  }
  
  saveOrderTypeSelection(orderType) {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content
    
    fetch('/pos/set_order_type', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken,
        'Accept': 'application/json'
      },
      body: JSON.stringify({
        order_type: orderType
      })
    })
    .then(response => {
      if (!response.ok) {
        throw new Error('Network response was not ok');
      }
      return response.json();
    })
    .then(data => {
      console.log('Order type saved successfully:', data);
    })
    .catch(error => {
      console.error('Error saving order type selection:', error);
    });
  }
}
