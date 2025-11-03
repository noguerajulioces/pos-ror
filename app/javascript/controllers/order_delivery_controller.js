import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  assign(event) {
    const deliveryUserId = event.target.value
    const orderId = event.target.dataset.orderId

    if (!deliveryUserId) {
      return
    }

    fetch(`/orders/${orderId}/assign_delivery_user`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({ delivery_user_id: deliveryUserId })
    })
    .then(response => response.json())
    .then(data => {
      if (data.success || data.redirect_url) {
        // Reload the page to show updated delivery assignment
        window.location.reload()
      } else {
        alert(data.error || 'Error al asignar el repartidor')
      }
    })
    .catch(error => {
      console.error('Error:', error)
      alert('Error al procesar la solicitud')
    })
  }
}

