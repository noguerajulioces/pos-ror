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
}