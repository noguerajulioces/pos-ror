import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["results"]

  connect() {
    console.log("Customer search controller connected")
  }

  search(event) {
    const query = event.target.value.trim()
    
    if (query.length < 2) {
      this.showEmptyState()
      return
    }
    
    // Fetch results from server
    fetch(`/customers/search?query=${encodeURIComponent(query)}`)
      .then(response => response.json())
      .then(data => {
        this.renderResults(data)
      })
      .catch(error => {
        console.error("Error searching customers:", error)
        this.showError()
      })
  }
  
  renderResults(customers) {
    const resultsContainer = document.getElementById("customer-search-results")
    
    if (customers.length === 0) {
      resultsContainer.innerHTML = `
        <div class="text-center text-gray-500 py-4">
          No se encontraron clientes con ese criterio de búsqueda
        </div>
      `
      return
    }
    
    const html = customers.map(customer => `
      <div class="border-b border-gray-200 last:border-0 py-2 px-3 hover:bg-gray-50 cursor-pointer"
           data-action="click->customer-search#selectCustomer"
           data-customer-id="${customer.id}"
           data-customer-name="${customer.name}">
        <div class="font-medium">${customer.name}</div>
        <div class="text-sm text-gray-500">${customer.phone || 'Sin teléfono'}</div>
      </div>
    `).join('')
    
    resultsContainer.innerHTML = html
  }
  
  showEmptyState() {
    const resultsContainer = document.getElementById("customer-search-results")
    resultsContainer.innerHTML = `
      <div class="text-center text-gray-500 py-4">
        Ingrese un término de búsqueda para encontrar clientes
      </div>
    `
  }
  
  showError() {
    const resultsContainer = document.getElementById("customer-search-results")
    resultsContainer.innerHTML = `
      <div class="text-center text-red-500 py-4">
        Ocurrió un error al buscar clientes
      </div>
    `
  }
  
  search() {
    const query = this.element.value.trim()
    if (query.length < 2) return

    const csrfToken = document.querySelector('meta[name="csrf-token"]').content
    
    fetch(`/customers/search?query=${encodeURIComponent(query)}`, {
      headers: {
        "X-CSRF-Token": csrfToken,
        "Accept": "text/html"
      }
    })
    .then(response => response.text())
    .then(html => {
      document.getElementById("customer-search-results").innerHTML = html
    })
    .catch(error => {
      console.error("Error searching customers:", error)
    })
  }

  createCustomer(event) {
    event.preventDefault()
    const form = event.target.closest('form')
    const formData = new FormData(form)
    
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content
    
    fetch(form.action, {
      method: 'POST',
      headers: {
        "X-CSRF-Token": csrfToken,
        "Accept": "application/json"
      },
      body: formData
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        // Close modal and update customer info
        const modal = document.querySelector('[data-controller="modal"]')
        if (modal) {
          const modalController = modal.controller
          modalController.close()
        }
        
        // Update customer info in the POS screen
        document.getElementById("customer-info").textContent = data.customer.name
        
        // Show success message
        alert(`Cliente ${data.customer.name} creado exitosamente`)
      } else {
        // Show errors
        alert(`Error: ${data.errors.join(', ')}`)
      }
    })
    .catch(error => {
      console.error("Error creating customer:", error)
    })
  }

  selectCustomer(event) {
    const customerId = event.currentTarget.dataset.customerId
    const customerName = event.currentTarget.dataset.customerName
    
    // Update customer info in the POS screen
    document.getElementById("customer-info").textContent = customerName
    
    // Close modal
    const modal = document.querySelector('[data-controller="modal"]')
    if (modal) {
      const modalController = modal.controller
      modalController.close()
    }
  }
}