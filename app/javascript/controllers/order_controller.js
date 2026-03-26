import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  printKitchen() {
    fetch('/pos/print_kitchen', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      }
    })
    .then(response => response.json())
    .then(data => {
      if (data.success && data.kitchen_print_url) {
        this._openKitchenPrint(data.kitchen_print_url)
      } else {
        alert(data.error || 'No hay items pendientes para cocina')
      }
    })
    .catch(error => {
      console.error('Error al imprimir cocina:', error)
      alert('Error al conectar con el servidor')
    })
  }

  _openKitchenPrint(url) {
    const iframe = document.createElement('iframe')
    iframe.style.cssText = 'position:fixed;right:0;bottom:0;width:0;height:0;border:0;'
    iframe.src = url
    document.body.appendChild(iframe)
    iframe.onload = () => {
      setTimeout(() => {
        try {
          iframe.contentWindow.focus()
          iframe.contentWindow.print()
        } catch(e) {
          console.error('Error al imprimir ticket de cocina:', e)
        }
        setTimeout(() => document.body.removeChild(iframe), 60000)
      }, 500)
    }
  }

  createOnHold() {
    // Check if cart is empty
    const cartItemsBody = document.getElementById('cart-items-body');
    if (cartItemsBody.querySelector('td[colspan="4"]')) {
      alert('No hay productos en el carrito');
      return;
    }

    // Get customer and order type
    const customerIdElement = document.getElementById('selected-customer-id-mobile') || document.getElementById('selected-customer-id');
    const customerId = customerIdElement ? customerIdElement.value : null;
    const orderTypeElement = document.getElementById('selected-order-type');
    const orderType = orderTypeElement ? orderTypeElement.value : 'in_store';

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