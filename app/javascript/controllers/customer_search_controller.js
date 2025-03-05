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
  
  selectCustomer(event) {
    const customerId = event.currentTarget.dataset.customerId
    const customerName = event.currentTarget.dataset.customerName
    
    // Update the customer display in the order summary
    const customerDisplay = document.querySelector('.px-4.py-3.border-b.border-gray-200:nth-child(2) .float-right.font-medium')
    if (customerDisplay) {
      customerDisplay.textContent = customerName
    }
    
    // Close the modal
    const modal = event.currentTarget.closest('.fixed')
    if (modal) {
      modal.remove()
    }
    
    // You might want to store the selected customer ID in a hidden field or make an AJAX request
    // to update the current order with this customer
  }
}