import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["option", "tableContainer", "tableSelect"]
  static values = { 
    tablesUrl: String,
    isMesero: Boolean,
    isMobile: Boolean
  }
  
  connect() {
    // Si es mesero en mobile, automáticamente establecer tipo de pedido y cargar mesas
    if (this.isMeseroValue && this.isMobileValue) {
      this.setOrderType("in_store")
      this.showTableSelection()
    } else {
      // Configurar el estado inicial visual para los demás
      const hiddenInput = document.getElementById('modal-selected-order-type');
      if (hiddenInput && hiddenInput.value) {
        this.updateVisualSelection(hiddenInput.value);
      }
    }
  }
  
  selectType(event) {
    event.preventDefault()
    const orderType = event.currentTarget.dataset.orderType;
    this.updateVisualSelection(orderType);
    this.setOrderType(orderType)
  }

  updateVisualSelection(orderType) {
    const btnDelivery = document.getElementById('btn-delivery');
    const btnInStore = document.getElementById('btn-in-store');
    
    if (orderType === "delivery") {
      if (btnDelivery) {
        btnDelivery.classList.add('border-indigo-500', 'bg-indigo-50', 'border-2');
        btnDelivery.classList.remove('border');
      }
      
      if (btnInStore) {
        btnInStore.classList.remove('border-indigo-500', 'bg-indigo-50', 'border-2');
        btnInStore.classList.add('border');
      }
      
      this.hideTableSelection()
    } else {
      if (btnInStore) {
        btnInStore.classList.add('border-indigo-500', 'bg-indigo-50', 'border-2');
        btnInStore.classList.remove('border');
      }
      
      if (btnDelivery) {
        btnDelivery.classList.remove('border-indigo-500', 'bg-indigo-50', 'border-2');
        btnDelivery.classList.add('border');
      }
      
      this.showTableSelection()
    }
  }

  setOrderType(orderType) {
    const hiddenInput = document.getElementById('modal-selected-order-type');
    if (hiddenInput) {
      hiddenInput.value = orderType;
    }
  }
  
  showTableSelection() {
    if (this.hasTableContainerTarget) {
      this.tableContainerTarget.classList.remove("hidden")
      this.loadTables()
    }
  }
  
  hideTableSelection() {
    if (this.hasTableContainerTarget) {
      this.tableContainerTarget.classList.add("hidden")
      // Clear select if hidden
      if (this.hasTableSelectTarget) {
        this.tableSelectTarget.value = "";
      }
    }
  }
  
  loadTables() {
    if (!this.tablesUrlValue) {
      return
    }
    
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content
    
    fetch(this.tablesUrlValue, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken,
        'Accept': 'application/json'
      }
    })
    .then(response => response.json())
    .then(data => {
      if (this.hasTableSelectTarget) {
        // Only load if it's currently empty (has just the placeholder)
        if (this.tableSelectTarget.options.length <= 1) {
          this.tableSelectTarget.innerHTML = '<option value="">-- Seleccione una mesa --</option>'
          data.forEach(table => {
            const option = document.createElement('option')
            option.value = table.id
            option.textContent = table.name
            this.tableSelectTarget.appendChild(option)
          })
        }
      }
    })
    .catch(error => {
      console.error('Error loading tables:', error)
    })
  }
}
