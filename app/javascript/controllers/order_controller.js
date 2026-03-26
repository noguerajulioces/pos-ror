import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  printKitchen() {
    fetch('/pos/pending_kitchen_items', {
      headers: { 'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content }
    })
    .then(response => response.json())
    .then(data => {
      if (data.error) {
        alert(data.error)
        return
      }
      if (data.items && data.items.length > 0) {
        this._showKitchenSelectionModal(data.items)
      } else {
        alert('No hay items en el pedido')
      }
    })
    .catch(error => {
      console.error('Error al obtener items de cocina:', error)
      alert('Error al conectar con el servidor')
    })
  }

  _showKitchenSelectionModal(items, onClose = null, orderId = null) {
    const rows = items.map(item => {
      const checked = item.pending ? 'checked' : ''
      const badgeNew = item.pending
        ? `<span class="text-xs bg-orange-100 text-orange-700 font-semibold px-2 py-0.5 rounded-full">+${item.delta % 1 === 0 ? item.delta : item.delta}</span>`
        : `<span class="text-xs bg-gray-100 text-gray-500 px-2 py-0.5 rounded-full">enviado</span>`
      const borderClass = item.pending ? 'border-orange-300 bg-orange-50' : 'border-gray-200'
      return `
        <label class="flex items-center gap-3 p-3 rounded-lg border ${borderClass} hover:bg-orange-50 cursor-pointer">
          <input type="checkbox" value="${item.id}" ${checked}
                 class="kitchen-item-check w-5 h-5 rounded accent-orange-500">
          <span class="flex-1 font-medium text-gray-800">${item.name}</span>
          <span class="font-bold text-gray-700 mr-1">x${item.quantity % 1 === 0 ? item.quantity : item.quantity}</span>
          ${badgeNew}
        </label>
      `
    }).join('')

    const modalHTML = `
      <div id="kitchen-selection-modal" data-order-id="${orderId || ''}" class="fixed inset-0 bg-gray-500 bg-opacity-75 flex items-center justify-center p-4 z-[70]">
        <div class="bg-white rounded-lg shadow-xl w-full max-w-sm flex flex-col max-h-[90vh]">
          <div class="flex items-center justify-between p-4 border-b flex-shrink-0">
            <h3 class="text-lg font-semibold text-gray-900">Enviar a Cocina</h3>
            <button id="kitchen-modal-close" class="text-gray-400 hover:text-gray-500">
              <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
              </svg>
            </button>
          </div>
          <div class="p-4 overflow-y-auto flex-1 space-y-2">
            ${rows}
          </div>
          <div class="p-4 border-t flex-shrink-0">
            <button id="kitchen-print-confirm"
                    class="w-full bg-orange-500 hover:bg-orange-600 text-white font-semibold py-3 rounded-lg transition-colors">
              Imprimir seleccionados
            </button>
          </div>
        </div>
      </div>
    `

    document.body.insertAdjacentHTML('beforeend', modalHTML)

    document.getElementById('kitchen-modal-close').addEventListener('click', () => {
      document.getElementById('kitchen-selection-modal').remove()
      if (onClose) onClose()
    })

    document.getElementById('kitchen-print-confirm').addEventListener('click', () => {
      const checked = Array.from(document.querySelectorAll('.kitchen-item-check:checked')).map(cb => cb.value)
      if (checked.length === 0) {
        alert('Selecciona al menos un item')
        return
      }
      const orderId = document.getElementById('kitchen-selection-modal').dataset.orderId
      document.getElementById('kitchen-selection-modal').remove()
      this._submitKitchenPrint(checked, orderId, onClose)
    })
  }

  _submitKitchenPrint(itemIds, orderId = null, onDone = null) {
    fetch('/pos/print_kitchen', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({ item_ids: itemIds, order_id: orderId })
    })
    .then(response => response.json())
    .then(data => {
      if (data.success && data.kitchen_print_url) {
        this._openKitchenPrint(data.kitchen_print_url)
      } else {
        alert(data.error || 'Error al imprimir')
      }
      if (onDone) onDone()
    })
    .catch(error => {
      console.error('Error al imprimir cocina:', error)
      alert('Error al conectar con el servidor')
      if (onDone) onDone()
    })
  }

  _reloadCart() {
    fetch('/pos/reload_cart', {
      method: 'POST',
      headers: {
        'Accept': 'text/vnd.turbo-stream.html',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      }
    })
    .then(response => response.text())
    .then(html => Turbo.renderStreamMessage(html))
    .catch(error => console.error('Error recargando carrito:', error))
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

  createAndPrint() {
    const cartItemsBody = document.getElementById('cart-items-body')
    if (cartItemsBody.querySelector('td[colspan="4"]')) {
      alert('No hay productos en el carrito')
      return
    }

    const customerIdElement = document.getElementById('selected-customer-id-mobile') || document.getElementById('selected-customer-id')
    const customerId = customerIdElement ? customerIdElement.value : null
    const orderTypeElement = document.getElementById('selected-order-type')
    const orderType = orderTypeElement ? orderTypeElement.value : 'in_store'

    fetch('/pos/create_order', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({ status: 'on_hold', customer_id: customerId, order_type: orderType })
    })
    .then(response => response.json())
    .then(data => {
      if (!data.success) {
        alert(data.error || 'Error al guardar el pedido')
        return
      }
      // Order saved — now fetch kitchen items using the returned order_id
      return fetch(`/pos/pending_kitchen_items?order_id=${data.order_id}`, {
        headers: { 'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content }
      })
    })
    .then(response => response && response.json())
    .then(data => {
      if (!data) return
      if (data.error) { window.location.href = '/pos'; return }
      if (data.items && data.items.length > 0) {
        this._showKitchenSelectionModal(data.items, () => this._reloadCart(), data.order_id)
      } else {
        this._reloadCart()
      }
    })
    .catch(error => {
      console.error('Error:', error)
      alert('Error al procesar la solicitud')
    })
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