import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["option", "tableContainer", "tableSelect"]
  static values = { tablesUrl: String }
  
  connect() {
    console.log("Order type controller connected")
  }
  
  selectType(event) {
    event.preventDefault()
    // Make sure we use the exact enum values from the Order model
    const orderType = event.currentTarget.dataset.orderType === "Delivery" ? "delivery" : "in_store"
    console.log("Selected order type:", orderType)
    
    // Update the order type display in the POS view
    const orderTypeDisplay = document.getElementById("order-type-display")
    if (orderTypeDisplay) {
      // Keep the display text user-friendly while sending the correct value to the backend
      orderTypeDisplay.textContent = orderType === "delivery" ? "Delivery" : "En el local"
    } else {
      console.error("Could not find order-type-display element")
    }
    
    // Update hidden input with order type
    const orderTypeInput = document.getElementById("selected-order-type")
    if (orderTypeInput) {
      orderTypeInput.value = orderType
    } else {
      console.error("Could not find selected-order-type element")
    }
    
    // Show table selection if in_store, hide if delivery
    if (orderType === "in_store") {
      this.showTableSelection()
    } else {
      this.hideTableSelection()
      // Clear table selection when switching to delivery
      this.saveTableSelection(null)
    }
    
    // Save order type selection to session
    this.saveOrderTypeSelection(orderType)
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
    }
  }
  
  loadTables() {
    if (!this.tablesUrlValue) {
      console.error("Tables URL not configured")
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
        // Clear existing options except the first one
        this.tableSelectTarget.innerHTML = '<option value="">-- Seleccione una mesa --</option>'
        
        // Add table options
        data.forEach(table => {
          const option = document.createElement('option')
          option.value = table.id
          option.textContent = table.name
          this.tableSelectTarget.appendChild(option)
        })
        
        // Add change event listener
        this.tableSelectTarget.addEventListener('change', (e) => {
          this.saveTableSelection(e.target.value)
        })
      }
    })
    .catch(error => {
      console.error('Error loading tables:', error)
    })
  }
  
  saveTableSelection(tableId) {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content
    
    fetch('/pos/set_table', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken,
        'Accept': 'application/json'
      },
      body: JSON.stringify({
        table_id: tableId || null
      })
    })
    .then(response => response.json())
    .then(data => {
      console.log('Table selection saved:', data)
      
      // Update table display in the POS view
      const tableDisplay = document.getElementById('table-display')
      const tableSelect = this.hasTableSelectTarget ? this.tableSelectTarget : null
      
      if (tableId && tableSelect) {
        const selectedOption = tableSelect.options[tableSelect.selectedIndex]
        const tableName = selectedOption ? selectedOption.textContent : ''
        
        // Update or create table display
        if (tableDisplay) {
          tableDisplay.textContent = tableName
        } else {
          // Create table display if it doesn't exist
          const orderTypeDiv = document.querySelector('#order-type-display')?.parentElement
          if (orderTypeDiv) {
            const tableDiv = document.createElement('div')
            tableDiv.className = 'mt-1'
            tableDiv.innerHTML = `
              <span class="text-xs text-gray-500">Mesa:</span>
              <span class="float-right text-xs font-medium text-indigo-600" id="table-display">${tableName}</span>
            `
            orderTypeDiv.appendChild(tableDiv)
          }
        }
      } else if (tableDisplay) {
        // Remove table display if no table is selected
        tableDisplay.parentElement.remove()
      }
    })
    .catch(error => {
      console.error('Error saving table selection:', error)
    })
  }
  
  saveOrderTypeSelection(orderType) {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content
    
    fetch('/pos/set_order_type', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken,
        'Accept': 'application/json'
      },
      body: JSON.stringify({
        order_type: orderType
      })
    })
    .then(response => {
      if (!response.ok) {
        throw new Error('Network response was not ok');
      }
      return response.json();
    })
    .then(data => {
      console.log('Order type saved successfully:', data);
    })
    .catch(error => {
      console.error('Error saving order type selection:', error);
    });
  }
}
