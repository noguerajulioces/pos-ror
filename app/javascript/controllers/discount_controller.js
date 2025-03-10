import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["fixedRadio", "percentageRadio", "symbol", "percentageSymbol", "amount"]

  connect() {
    // Set initial state
    this.toggleSymbols()
  }

  toggleSymbols() {
    if (this.fixedRadioTarget.checked) {
      this.symbolTarget.textContent = 'GS.'
      this.symbolTarget.classList.remove('hidden')
      this.percentageSymbolTarget.classList.add('hidden')
    } else {
      this.symbolTarget.textContent = ''
      this.symbolTarget.classList.add('hidden')
      this.percentageSymbolTarget.classList.remove('hidden')
    }
  }

  apply() {
    const discountAmount = this.amountTarget.value
    const discountType = this.fixedRadioTarget.checked ? 'fixed' : 'percentage'
    
    if (!discountAmount || isNaN(discountAmount) || discountAmount < 0) {
      alert('Por favor ingrese un monto de descuento válido')
      return
    }
    
    // Send discount to server
    fetch('/pos/apply_discount', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({
        discount_amount: discountAmount,
        discount_type: discountType
      })
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        // Update totals in the UI
        document.getElementById('cart-discount').textContent = data.formatted_discount
        document.getElementById('cart-total').textContent = data.formatted_total
        document.getElementById('cart-subtotal').textContent = data.formatted_subtotal
        document.getElementById('cart-iva').textContent = data.formatted_iva
        
        // Close the modal
        const modalController = this.application.getControllerForElementAndIdentifier(
          document.querySelector('[data-controller="modal"]'),
          'modal'
        )
        if (modalController) modalController.close()
      } else {
        alert(data.error || 'Error al aplicar el descuento')
      }
    })
    .catch(error => {
      console.error('Error:', error)
      alert('Error al procesar la solicitud')
    })
  }
}