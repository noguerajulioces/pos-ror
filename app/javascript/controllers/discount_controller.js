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
        console.log("DATA ", data);
        // Helper function to update an element if it exists
        const updateElement = (id, value) => {
          const element = document.getElementById(id);
          if (element) {
            element.textContent = value;
          }
        };

        // Update totals in the UI for both mobile and desktop
        updateElement('cart-discount-mobile', data.formatted_discount);
        updateElement('cart-discount-desktop', data.formatted_discount);
        
        // Store the fixed discount amount in a data attribute for future reference
        if (discountType === 'fixed') {
          const mobileDiscount = document.getElementById('cart-discount-mobile');
          const desktopDiscount = document.getElementById('cart-discount-desktop');
          if (mobileDiscount) mobileDiscount.dataset.fixedAmount = discountAmount;
          if (desktopDiscount) desktopDiscount.dataset.fixedAmount = discountAmount;
        } else {
          const mobileDiscount = document.getElementById('cart-discount-mobile');
          const desktopDiscount = document.getElementById('cart-discount-desktop');
          if (mobileDiscount) delete mobileDiscount.dataset.fixedAmount;
          if (desktopDiscount) delete desktopDiscount.dataset.fixedAmount;
        }
        
        updateElement('cart-total-mobile', data.formatted_total);
        updateElement('cart-total-desktop', data.formatted_total);
        updateElement('cart-subtotal-mobile', data.formatted_subtotal);
        updateElement('cart-subtotal-desktop', data.formatted_subtotal);
        updateElement('cart-iva-mobile', data.formatted_iva);
        updateElement('cart-iva-desktop', data.formatted_iva);
        
        // Update the discount label if provided (both mobile and desktop)
        if (data.discount_label) {
          let labelText = data.discount_label;
          
          // For fixed discount, we might want to show the original amount if it's different
          if (discountType === 'fixed' && data.discount < discountAmount) {
            const originalAmount = new Intl.NumberFormat('es-PY', { 
              style: 'currency', 
              currency: 'PYG',
              currencyDisplay: 'narrowSymbol',
              minimumFractionDigits: 0
            }).format(discountAmount).replace('PYG', '₲s.');
            
            labelText = `Descuento (${originalAmount})`;
          }
          
          updateElement('discount-label-mobile', labelText);
          updateElement('discount-label-desktop', labelText);
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