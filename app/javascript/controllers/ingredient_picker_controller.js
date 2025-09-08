import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results", "loading", "createForm", "createFormElement"]
  static values = { productId: Number }

  connect() {
    this.searchTimeout = null
  }

  disconnect() {
    if (this.searchTimeout) {
      clearTimeout(this.searchTimeout)
    }
  }

  search() {
    const query = this.inputTarget.value.trim()
    
    if (query.length < 2) {
      this.showEmptyState()
      return
    }

    this.showLoading()
    
    // Clear previous timeout
    if (this.searchTimeout) {
      clearTimeout(this.searchTimeout)
    }

    // Debounce search
    this.searchTimeout = setTimeout(() => {
      this.performSearch(query)
    }, 300)
  }

  async performSearch(query) {
    try {
      const response = await fetch(`/ingredients/search?q=${encodeURIComponent(query)}`, {
        headers: {
          'Accept': 'text/vnd.turbo-stream.html',
          'X-Requested-With': 'XMLHttpRequest'
        }
      })

      if (response.ok) {
        const html = await response.text()
        this.resultsTarget.innerHTML = html
      } else {
        this.showError("Error al buscar ingredientes")
      }
    } catch (error) {
      console.error('Search error:', error)
      this.showError("Error de conexión")
    } finally {
      this.hideLoading()
    }
  }

  selectIngredient(event) {
    const button = event.currentTarget
    const ingredientId = button.dataset.ingredientId
    const ingredientName = button.dataset.ingredientName
    const ingredientUnitId = button.dataset.ingredientUnitId

    this.createRecipeComponent(ingredientId, ingredientName, ingredientUnitId)
  }

  async createRecipeComponent(ingredientId, ingredientName, ingredientUnitId) {
    try {
      const formData = new FormData()
      formData.append('recipe_component[ingredient_id]', ingredientId)
      formData.append('recipe_component[quantity]', '1')
      formData.append('recipe_component[unit_id]', ingredientUnitId || '')
      formData.append('recipe_component[waste_pct]', '0')

      const response = await fetch(`/products/${this.productIdValue}/products/recipe_components`, {
        method: 'POST',
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
          'Accept': 'text/vnd.turbo-stream.html',
          'X-Requested-With': 'XMLHttpRequest'
        },
        body: formData
      })

      if (response.ok) {
        const html = await response.text()
        Turbo.renderStreamMessage(html)
      } else {
        this.showError("Error al agregar ingrediente")
      }
    } catch (error) {
      console.error('Create recipe component error:', error)
      this.showError("Error de conexión")
    }
  }

  showCreateForm(event) {
    const button = event.currentTarget
    const ingredientName = button.dataset.ingredientName
    
    // Set the ingredient name in the form
    const nameInput = this.createFormElementTarget.querySelector('input[name="ingredient[name]"]')
    if (nameInput) {
      nameInput.value = ingredientName
    }
    
    this.resultsTarget.classList.add('hidden')
    this.createFormTarget.classList.remove('hidden')
  }

  hideCreateForm() {
    this.createFormTarget.classList.add('hidden')
    this.resultsTarget.classList.remove('hidden')
    this.inputTarget.value = ''
    this.showEmptyState()
  }

  showLoading() {
    this.loadingTarget.classList.remove('hidden')
    this.resultsTarget.classList.add('hidden')
  }

  hideLoading() {
    this.loadingTarget.classList.add('hidden')
    this.resultsTarget.classList.remove('hidden')
  }

  showEmptyState() {
    this.resultsTarget.innerHTML = `
      <div class="text-center py-8 text-gray-500">
        <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
        </svg>
        <p class="mt-2 text-sm">Escribe para buscar ingredientes</p>
      </div>
    `
  }

  showError(message) {
    this.resultsTarget.innerHTML = `
      <div class="text-center py-8 text-red-500">
        <svg class="mx-auto h-12 w-12 text-red-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z"></path>
        </svg>
        <p class="mt-2 text-sm">${message}</p>
      </div>
    `
  }
}
