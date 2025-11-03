import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("Order search controller connected")
  }

  search() {
    const query = this.element.value.trim()
    const ordersList = document.getElementById('orders-list')
    
    if (!query) {
      // If query is empty, reload all orders
      window.location.href = '/pos/modals/orders'
      return
    }

    // Filter orders client-side based on the query
    const orderCards = ordersList.querySelectorAll('.border.rounded-lg')
    
    orderCards.forEach(card => {
      const orderText = card.textContent.toLowerCase()
      if (orderText.includes(query.toLowerCase())) {
        card.style.display = ''
      } else {
        card.style.display = 'none'
      }
    })
  }

  loadToCart(event) {
    const orderId = event.currentTarget.dataset.orderId
    
    fetch(`/pos/load_order_to_cart/${orderId}`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      }
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        alert(`Pedido #${orderId} cargado al carrito correctamente`)
        window.location.reload()
      } else {
        alert(data.error || 'Error al cargar el pedido')
      }
    })
    .catch(error => {
      console.error('Error loading order:', error)
      alert('Error al procesar la solicitud')
    })
  }
}
