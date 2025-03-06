import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["query"]

  connect() {
    console.log("Product search controller connected")
  }

  search() {
    const query = this.queryTarget.value.trim()
    
    if (query.length < 2) {
      this.showCategories()
      return
    }
    
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content
    
    fetch(`/pos/search_products?query=${encodeURIComponent(query)}`, {
      headers: {
        "X-CSRF-Token": csrfToken,
        "Accept": "application/json"
      }
    })
    .then(response => response.json())
    .then(data => {
      this.renderSearchResults(data.products)
      this.hideCategories()
      this.showSearchResults()
    })
    .catch(error => {
      console.error("Error searching products:", error)
    })
  }
  
  renderSearchResults(products) {
    const resultsContainer = document.getElementById("search-results-list")
    
    if (products.length === 0) {
      resultsContainer.innerHTML = `
        <div class="w-full text-center text-gray-500 py-4">
          No se encontraron productos con ese criterio de búsqueda
        </div>
      `
      return
    }
    
    const html = products.map(product => `
      <div class="w-1/3 p-3" data-controller="product" data-product-id="${product.id}">
        <div class="border rounded-lg overflow-hidden shadow-sm hover:shadow-md transition-shadow cursor-pointer"
             data-action="click->product#addToCart">
          <div class="h-32 bg-gray-100 flex items-center justify-center">
            ${product.image_url ? 
              `<img src="${product.image_url}" alt="${product.name}" class="h-full object-cover">` : 
              `<div class="text-gray-400 text-4xl">📷</div>`
            }
          </div>
          <div class="p-3">
            <h3 class="font-medium text-gray-800 truncate">${product.name}</h3>
            <div class="flex justify-between items-center mt-2">
              <span class="text-green-600 font-medium">GS. ${new Intl.NumberFormat('es-PY').format(product.price)}</span>
              <button class="text-indigo-600 hover:text-indigo-800">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
                </svg>
              </button>
            </div>
          </div>
        </div>
      </div>
    `).join('')
    
    resultsContainer.innerHTML = html
  }
  
  clearSearch() {
    this.queryTarget.value = ""
    this.showCategories()
  }
  
  showCategories() {
    document.getElementById("categories-container").classList.remove("hidden")
    document.getElementById("subcategories-container").classList.add("hidden")
    document.getElementById("products-container").classList.add("hidden")
    document.getElementById("search-results-container").classList.add("hidden")
  }
  
  hideCategories() {
    document.getElementById("categories-container").classList.add("hidden")
    document.getElementById("subcategories-container").classList.add("hidden")
    document.getElementById("products-container").classList.add("hidden")
  }
  
  showSearchResults() {
    document.getElementById("search-results-container").classList.remove("hidden")
  }
}