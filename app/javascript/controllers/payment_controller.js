import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["methodId", "amountReceived", "changeAmount"]

  connect() {
    console.log("Payment controller connected")
  }

  selectMethod(event) {
    console.log("selectMethod called")
    
    // Existing method selection code
    const methodId = event.currentTarget.dataset.paymentMethodId
    console.log("Payment method ID:", methodId)
    
    try {
      // Check if methodIdTarget exists before trying to access it
      if (this.hasOwnProperty('methodIdTarget') && this.methodIdTarget) {
        this.methodIdTarget.value = methodId
        console.log("methodIdTarget value set to:", this.methodIdTarget.value)
      } else {
        console.error("methodIdTarget is not available", this)
        // Fallback: try to find the element manually
        const methodIdInput = document.querySelector('input[name="payment_method_id"]')
        if (methodIdInput) {
          methodIdInput.value = methodId
          console.log("Set payment_method_id manually to:", methodId)
        } else {
          console.error("Could not find payment_method_id input element")
        }
      }
    } catch (error) {
      console.error("Error setting methodIdTarget value:", error)
    }

    // Remove selected class from all options
    console.log("Removing selected class from all options")
    document.querySelectorAll('.payment-method-option').forEach(option => {
      try {
        option.classList.remove('bg-gray-50', 'border-indigo-500')
        const radioSelected = option.querySelector('.payment-radio-selected')
        if (radioSelected) {
          radioSelected.classList.add('hidden')
        } else {
          console.warn("Radio selected element not found in option", option)
        }
      } catch (error) {
        console.error("Error removing classes:", error, option)
      }
    })

    // Add selected class to clicked option
    console.log("Adding selected class to clicked option")
    try {
      event.currentTarget.classList.add('bg-gray-50', 'border-indigo-500')
      const radioSelected = event.currentTarget.querySelector('.payment-radio-selected')
      if (radioSelected) {
        radioSelected.classList.remove('hidden')
      } else {
        console.warn("Radio selected element not found in clicked option")
      }
    } catch (error) {
      console.error("Error adding classes:", error)
    }
    
    console.log("selectMethod completed")
  }

  calculateChange() {
    const totalAmount = parseFloat(document.getElementById('total-amount-value').value)
    const amountReceived = parseFloat(this.amountReceivedTarget.value.replace(/\./g, '').replace(',', '.')) || 0
    
    if (!isNaN(amountReceived) && amountReceived >= totalAmount) {
      const change = amountReceived - totalAmount
      document.getElementById('change-amount').textContent = `₲s. ${this.formatNumber(change)}`
      this.changeAmountTarget.value = change
    } else {
      document.getElementById('change-amount').textContent = '₲s. 0'
      this.changeAmountTarget.value = 0
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