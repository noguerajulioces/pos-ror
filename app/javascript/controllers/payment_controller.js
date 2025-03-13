import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["methodId", "amountReceived", "changeAmount"]

  connect() {
    // Initialize any values if needed
  }

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
    
    // Store the selected payment method ID in the hidden field
    this.methodIdTarget.value = selectedOption.dataset.paymentMethodId;
  }
  
  calculateChange(event) {
    const amountReceived = parseFloat(this.amountReceivedTarget.value.replace(/[^\d]/g, '')) || 0;
    const totalAmount = parseFloat(document.getElementById('total-amount-value').value) || 0;
    
    let change = amountReceived - totalAmount;
    change = change > 0 ? change : 0;
    
    // Format the change amount with thousands separator
    const formattedChange = new Intl.NumberFormat('es-PY').format(change);
    document.getElementById('change-amount').textContent = `₲s. ${formattedChange}`;
    
    // Store the change amount in the hidden field
    this.changeAmountTarget.value = change;
  }
  
  validateBeforeSubmit(event) {
    // Check if a payment method is selected
    if (!this.methodIdTarget.value) {
      event.preventDefault();
      alert('Por favor seleccione un método de pago');
      return;
    }
    
    // Get the amount received
    const amountReceived = parseFloat(this.amountReceivedTarget.value.replace(/[^\d]/g, '')) || 0;
    
    // Get the total amount
    const totalAmount = parseFloat(document.getElementById('total-amount-value').value) || 0;
    
    // Validate the amount received
    if (amountReceived < totalAmount) {
      event.preventDefault();
      alert('El monto recibido debe ser mayor o igual al total a pagar');
      return;
    }
  }
}