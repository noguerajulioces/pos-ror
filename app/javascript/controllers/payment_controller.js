import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  selectMethod(event) {
    // Remove selection from all payment methods
    document.querySelectorAll('.payment-method-option').forEach(option => {
      option.classList.remove('bg-gray-100', 'border-indigo-500');
      option.querySelector('.payment-radio-selected').classList.add('hidden');
    });
    
    // Add selection to clicked payment method
    const selectedOption = event.currentTarget;
    selectedOption.classList.add('bg-gray-100', 'border-indigo-500');
    selectedOption.querySelector('.payment-radio-selected').classList.remove('hidden');
    
    // Store the selected payment method ID
    this.paymentMethodId = selectedOption.dataset.paymentMethodId;
  }
  
  calculateChange(event) {
    const amountReceived = parseFloat(event.currentTarget.value.replace(/[^\d]/g, '')) || 0;
    const totalAmount = parseFloat(document.getElementById('cart-total').textContent.replace(/[^\d]/g, '')) || 0;
    
    let change = amountReceived - totalAmount;
    change = change > 0 ? change : 0;
    
    // Format the change amount with thousands separator
    const formattedChange = new Intl.NumberFormat('es-PY').format(change);
    document.getElementById('change-amount').textContent = `₲s. ${formattedChange}`;
  }
  
  processPayment() {
    // Check if a payment method is selected
    if (!this.paymentMethodId) {
      alert('Por favor seleccione un método de pago');
      return;
    }
    
    // Get the amount received
    const amountReceivedInput = document.getElementById('amount-received');
    const amountReceived = parseFloat(amountReceivedInput.value.replace(/[^\d]/g, '')) || 0;
    
    // Get the total amount
    const totalAmount = parseFloat(document.getElementById('cart-total').textContent.replace(/[^\d]/g, '')) || 0;
    
    // Validate the amount received
    if (amountReceived < totalAmount) {
      alert('El monto recibido debe ser mayor o igual al total a pagar');
      return;
    }
    
    // Get customer ID
    const customerId = document.getElementById('selected-customer-id').value;
    
    // Get order type
    const orderType = document.getElementById('selected-order-type').value;
    
    // Send request to create the order and process payment
    fetch('/pos/create_order', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({
        po: {
          status: 'completed',
          customer_id: customerId,
          order_type: orderType,
          payment_method_id: this.paymentMethodId,
          amount_received: amountReceived,
          change_amount: amountReceived - totalAmount
        }
      })
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        // Close the modal
        const modal = document.querySelector('[data-controller="modal"]');
        if (modal) {
          const closeEvent = new Event('modal:close');
          modal.dispatchEvent(closeEvent);
        }
        
        // Clear the cart display
        document.getElementById('cart-items-body').innerHTML = `
          <tr>
            <td colspan="4" class="px-4 py-6 text-center text-gray-500">
              No se han añadido productos...
            </td>
          </tr>
        `;
        
        // Reset totals
        document.getElementById('cart-subtotal').textContent = '₲s. 0';
        document.getElementById('cart-iva').textContent = '₲s. 0';
        document.getElementById('cart-discount').textContent = '₲s. 0';
        document.getElementById('cart-total').textContent = '₲s. 0';
        
        // Reset discount label
        document.getElementById('discount-label').textContent = 'Descuento';
        
        // Show success message
        alert(`Pago procesado correctamente. Orden #${data.order_id} completada.`);
        
        // Optionally redirect to the order details page
        // window.location.href = `/orders/${data.order_id}`;
      } else {
        alert(data.error || 'Error al procesar el pago');
      }
    })
    .catch(error => {
      console.error('Error:', error);
      alert('Error al procesar la solicitud');
    });
  }
}