import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["fixedRadio", "percentageRadio", "symbol", "percentageSymbol", "amount"]

  connect() {
    console.log("Discount controller connected!")
    console.log("Targets available:", {
      fixedRadio: this.hasFixedRadioTarget,
      percentageRadio: this.hasPercentageRadioTarget,
      symbol: this.hasSymbolTarget,
      percentageSymbol: this.hasPercentageSymbolTarget,
      amount: this.hasAmountTarget
    })
    
    // Set initial state based on which radio is checked
    try {
      this.toggleSymbols()
      console.log("Initial toggle completed successfully")
    } catch (error) {
      console.error("Error during initial toggle:", error)
    }
  }

  toggleSymbols() {
    console.log("toggleSymbols called")
    console.log("Radio states:", {
      fixedChecked: this.fixedRadioTarget.checked,
      percentageChecked: this.percentageRadioTarget.checked
    })
    
    try {
      if (this.fixedRadioTarget.checked) {
        console.log("Fixed radio is checked, showing GS symbol")
        this.symbolTarget.classList.remove('hidden')
        this.percentageSymbolTarget.classList.add('hidden')
      } else if (this.percentageRadioTarget.checked) {
        console.log("Percentage radio is checked, showing % symbol")
        this.symbolTarget.classList.add('hidden')
        this.percentageSymbolTarget.classList.remove('hidden')
      }
      console.log("Symbol states after toggle:", {
        symbolHidden: this.symbolTarget.classList.contains('hidden'),
        percentageSymbolHidden: this.percentageSymbolTarget.classList.contains('hidden')
      })
    } catch (error) {
      console.error("Error in toggleSymbols:", error)
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
        if (document.getElementById('cart-discount')) {
          document.getElementById('cart-discount').textContent = data.formatted_discount
        }
        document.getElementById('cart-total').textContent = data.formatted_total
        document.getElementById('cart-subtotal').textContent = data.formatted_subtotal
        document.getElementById('cart-iva').textContent = data.formatted_iva
        
        // Update the discount label if provided
        if (data.discount_label && document.getElementById('discount-label')) {
          document.getElementById('discount-label').textContent = data.discount_label
        }
        
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