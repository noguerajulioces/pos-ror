import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["methodId", "amountReceived", "changeAmount"]

  connect() {
    console.log("Payment controller connected")
  }

  selectMethod(event) {
    // Existing method selection code
    const methodId = event.currentTarget.dataset.paymentMethodId
    this.methodIdTarget.value = methodId

    // Remove selected class from all options
    document.querySelectorAll('.payment-method-option').forEach(option => {
      option.classList.remove('bg-gray-50', 'border-indigo-500')
      option.querySelector('.payment-radio-selected').classList.add('hidden')
    })

    // Add selected class to clicked option
    event.currentTarget.classList.add('bg-gray-50', 'border-indigo-500')
    event.currentTarget.querySelector('.payment-radio-selected').classList.remove('hidden')
  }

  calculateChange() {
    const totalAmount = parseFloat(document.getElementById('total-amount-value').value)
    const amountReceived = parseFloat(this.amountReceivedTarget.value.replace(/\./g, '').replace(',', '.')) || 0
    
    if (!isNaN(amountReceived) && amountReceived >= totalAmount) {
      const change = amountReceived - totalAmount
      document.getElementById('change-amount').textContent = `₲s. ${this.formatNumber(change)}`
      this.changeAmountTarget.value = change
      
      // Update currency conversions
      this.updateCurrencyConversions(change)
    } else {
      document.getElementById('change-amount').textContent = '₲s. 0'
      this.changeAmountTarget.value = 0
      
      // Reset currency conversions
      this.updateCurrencyConversions(0)
    }
  }

  updateCurrencyConversions(changeAmount) {
    const currencyElements = document.querySelectorAll('.currency-value')
    
    currencyElements.forEach(element => {
      const rate = parseFloat(element.dataset.currencyRate)
      const symbol = element.dataset.currencySymbol
      
      if (rate && !isNaN(rate) && rate > 0) {
        const convertedAmount = (changeAmount / rate).toFixed(2)
        element.textContent = `${symbol} ${this.formatNumber(convertedAmount)}`
      } else {
        element.textContent = `${symbol} 0`
      }
    })
  }

  formatNumber(number) {
    return number.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ".")
  }

  validateBeforeSubmit(event) {
    const amountReceived = parseFloat(this.amountReceivedTarget.value.replace(/\./g, '').replace(',', '.')) || 0
    const totalAmount = parseFloat(document.getElementById('total-amount-value').value)
    
    if (amountReceived < totalAmount) {
      event.preventDefault()
      alert('El monto recibido debe ser mayor o igual al total a pagar')
    }
    
    if (!this.methodIdTarget.value) {
      event.preventDefault()
      alert('Debe seleccionar un método de pago')
    }
  }
}