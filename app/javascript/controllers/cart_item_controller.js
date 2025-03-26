import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { productId: String }

  remove(event) {
    event.preventDefault()
    
    fetch(`/pos/remove_from_cart?product_id=${this.productIdValue}`, {
      method: 'DELETE',
      headers: {
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
        'Content-Type': 'application/json',
        'Accept': 'text/vnd.turbo-stream.html'
      }
    })
    .then(response => response.text())
    .then(html => {
      Turbo.renderStreamMessage(html)
    })
  }
  
  updateQuantity(event) {
    const newQuantity = parseInt(event.target.value, 10)
    
    if (newQuantity < 1 || isNaN(newQuantity)) {
      event.target.value = 1
      return
    }
    
    fetch(`/pos/update_quantity?product_id=${this.productIdValue}&quantity=${newQuantity}`, {
      method: 'PATCH',
      headers: {
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
        'Accept': 'text/vnd.turbo-stream.html'
      }
    })
    .then(response => {
      if (!response.ok) {
        throw new Error('Network response was not ok')
      }
      return response.text()
    })
    .then(html => {
      Turbo.renderStreamMessage(html)
    })
    .catch(error => {
      console.error('Error updating quantity:', error)
      // Reset to previous value if there was an error
      event.target.value = event.target.defaultValue
    })
  }

  // Add these methods to your existing controller if they don't exist yet
  
  applyItemDiscount(event) {
    const productId = this.productIdValue
    const discountPercentage = event.target.value
    
    // Validate discount is between 0 and 100
    if (discountPercentage < 0 || discountPercentage > 100) {
      event.target.value = discountPercentage < 0 ? 0 : 100
      return
    }
    
    fetch('/pos/apply_item_discount', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
        'Accept': 'text/vnd.turbo-stream.html'
      },
      body: JSON.stringify({
        product_id: productId,
        discount_percentage: discountPercentage
      })
    })
    .then(response => response.text())
    .then(html => {
      Turbo.renderStreamMessage(html)
    })
    .catch(error => {
      console.error('Error applying item discount:', error)
    })
  }

  decrementQuantity(event) {
    const input = this.element.closest('tr').querySelector('input[type="number"]')
    const newValue = parseInt(input.value) - 1
    if (newValue >= 1) {
      input.value = newValue
      input.dispatchEvent(new Event('change'))
    }
  }

  incrementQuantity(event) {
    const input = this.element.closest('tr').querySelector('input[type="number"]')
    input.value = parseInt(input.value) + 1
    input.dispatchEvent(new Event('change'))
  }
  
  // Asegúrate de que estos métodos estén en tu cart_item_controller.js
  changeDiscountType(event) {
    const productId = this.productIdValue
    const discountTypeMode = event.target.value
    
    fetch(`/pos/change_discount_type`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({
        product_id: productId,
        discount_type_mode: discountTypeMode
      })
    })
    .catch(error => {
      console.error('Error:', error)
    })
  }
  
  applyDetailedDiscount(event) {
    event.preventDefault();
    
    const form = event.target;
    const formData = new FormData(form);
    
    fetch(form.action, {
      method: form.method,
      headers: {
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
        'Accept': 'application/json' // Explicitly request JSON response
      },
      body: formData
    })
    .then(response => {
      if (!response.ok) {
        throw new Error('Network response was not ok');
      }
      return response.json();
    })
    .then(data => {
      if (data.success) {
        // Cerrar el modal
        const modal = document.querySelector('[data-controller="modal"]');
        if (modal) {
          const modalController = this.application.getControllerForElementAndIdentifier(modal, "modal");
          if (modalController) {
            modalController.close();
          }
        }
        
        // Actualizar la vista del carrito
        Turbo.visit(window.location.href, { action: "replace" });
      }
    })
    .catch(error => {
      console.error('Error:', error);
    });
  }
}