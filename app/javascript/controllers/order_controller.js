import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  createOnHold() {
    // Check if cart is empty
    const cartItemsBody = document.getElementById('cart-items-body');
    if (cartItemsBody.querySelector('td[colspan="4"]')) {
      alert('No hay productos en el carrito');
      return;
    }

    // Get customer and order type
    const customerId = document.getElementById('selected-customer-id').value;
    const orderType = document.getElementById('selected-order-type').value;

    // Create the order with on_hold status
    fetch('/pos/create_order', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({
        status: 'on_hold',
        customer_id: customerId,
        order_type: orderType
      })
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        // Show success message
        alert('Pedido guardado en espera correctamente');
        
        // Clear the cart (optional - you might want to keep the cart)
        window.location.href = '/pos';
      } else {
        alert(data.error || 'Error al guardar el pedido');
      }
    })
    .catch(error => {
      console.error('Error:', error);
      alert('Error al procesar la solicitud');
    });
  }
}