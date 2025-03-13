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
  
  calculateChange() {
    const totalAmount = parseFloat(document.getElementById('total-amount-value').value);
    const amountReceived = parseFloat(this.amountReceivedTarget.value.replace(/\./g, '').replace(',', '.'));
    
    if (!isNaN(amountReceived) && amountReceived >= totalAmount) {
      const change = amountReceived - totalAmount;
      document.getElementById('change-amount').textContent = `₲s. ${this.formatNumber(change)}`;
      this.changeAmountTarget.value = change;
      
      // Update currency conversions
      this.updateCurrencyConversions(change);
    } else {
      document.getElementById('change-amount').textContent = '₲s. 0';
      this.changeAmountTarget.value = 0;
      
      // Reset currency conversions
      this.updateCurrencyConversions(0);
    }
  }

  updateCurrencyConversions(changeAmount) {
    const currencyElements = document.querySelectorAll('.currency-value');
    
    currencyElements.forEach(element => {
      const rate = parseFloat(element.dataset.currencyRate);
      const symbol = element.dataset.currencySymbol;
      
      if (rate && !isNaN(rate) && rate > 0) {
        const convertedAmount = (changeAmount / rate).toFixed(2);
        element.textContent = `${symbol} ${this.formatNumber(convertedAmount)}`;
      } else {
        element.textContent = `${symbol} 0`;
      }
    });
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