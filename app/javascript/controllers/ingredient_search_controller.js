import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "hiddenField", "options", "optionsList", "noResults", "toggleButton"]
  static values = { selectedValue: String }

  connect() {
    this.ingredients = []
    this.filteredIngredients = []
    this.selectedIndex = -1
    this.isOpen = false
    
    // Load ingredients on connect
    this.loadIngredients()
    
    // Set initial value if provided
    if (this.selectedValueValue) {
      this.setSelectedIngredient(this.selectedValueValue)
    }
    
    // Close dropdown when clicking outside
    document.addEventListener('click', this.handleClickOutside.bind(this))
    
    // Reposition dropdown on scroll/resize
    window.addEventListener('scroll', this.handleScroll.bind(this))
    window.addEventListener('resize', this.handleResize.bind(this))
  }

  disconnect() {
    document.removeEventListener('click', this.handleClickOutside.bind(this))
    window.removeEventListener('scroll', this.handleScroll.bind(this))
    window.removeEventListener('resize', this.handleResize.bind(this))
  }

  async loadIngredients() {
    try {
      const response = await fetch('/ingredients/search.json?q=', {
        headers: {
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest'
        }
      })
      
      if (response.ok) {
        this.ingredients = await response.json()
        this.filteredIngredients = this.ingredients
      }
    } catch (error) {
      console.error('Error loading ingredients:', error)
    }
  }

  search(event) {
    const query = event.target.value.toLowerCase().trim()
    
    if (query === '') {
      this.filteredIngredients = this.ingredients
    } else {
      this.filteredIngredients = this.ingredients.filter(ingredient => 
        ingredient.name.toLowerCase().includes(query) ||
        (ingredient.code && ingredient.code.toLowerCase().includes(query))
      )
    }
    
    this.selectedIndex = -1
    this.renderOptions()
    this.showOptions()
  }

  showOptions() {
    if (!this.isOpen) {
      this.isOpen = true
      this.optionsTarget.classList.remove('hidden')
      this.optionsTarget.style.zIndex = '9999'
      this.positionDropdown()
      this.renderOptions()
    }
  }

  positionDropdown() {
    // Always get fresh coordinates
    const inputRect = this.inputTarget.getBoundingClientRect()
    const dropdown = this.optionsTarget
    
    // Position dropdown exactly below the input with no gap
    // Use fixed positioning relative to viewport
    dropdown.style.position = 'fixed'
    dropdown.style.top = `${inputRect.bottom}px`
    dropdown.style.left = `${inputRect.left}px`
    dropdown.style.width = `${Math.max(inputRect.width, 300)}px` // Minimum 300px width
    dropdown.style.minWidth = `${inputRect.width}px`
  }

  hideOptions() {
    this.isOpen = false
    this.optionsTarget.classList.add('hidden')
  }

  toggleOptions() {
    if (this.isOpen) {
      this.hideOptions()
    } else {
      this.showOptions()
    }
  }

  // Override the showOptions method to always recalculate position
  focus() {
    this.showOptions()
  }

  click() {
    this.showOptions()
  }

  renderOptions() {
    if (this.filteredIngredients.length === 0) {
      this.optionsListTarget.innerHTML = ''
      this.noResultsTarget.classList.remove('hidden')
      return
    }
    
    this.noResultsTarget.classList.add('hidden')
    
    const optionsHtml = this.filteredIngredients.map((ingredient, index) => `
      <div class="block px-3 py-2 text-gray-900 cursor-pointer select-none hover:bg-indigo-600 hover:text-white ${index === this.selectedIndex ? 'bg-indigo-600 text-white' : ''}"
           data-action="click->ingredient-search#selectIngredient"
           data-ingredient-id="${ingredient.id}"
           data-ingredient-name="${ingredient.name}"
           data-index="${index}">
        <div class="flex justify-between items-center">
          <div class="flex-1 min-w-0">
            <div class="font-medium truncate">${ingredient.name}</div>
            ${ingredient.code ? `<div class="text-xs opacity-75">Código: ${ingredient.code}</div>` : ''}
          </div>
          <div class="ml-3 text-xs opacity-75 text-right flex-shrink-0">
            <div>Stock:</div>
            <div class="font-medium">${ingredient.stock || 0}</div>
          </div>
        </div>
      </div>
    `).join('')
    
    this.optionsListTarget.innerHTML = optionsHtml
  }

  selectIngredient(event) {
    const ingredientId = event.currentTarget.dataset.ingredientId
    const ingredientName = event.currentTarget.dataset.ingredientName
    
    this.inputTarget.value = ingredientName
    this.hiddenFieldTarget.value = ingredientId
    this.hideOptions()
    
    // Trigger change event for purchase-item-type controller
    const changeEvent = new Event('change', { bubbles: true })
    this.hiddenFieldTarget.dispatchEvent(changeEvent)
    
    // Notify parent controller about ingredient selection
    this.element.dispatchEvent(new CustomEvent('ingredient:selected', {
      detail: { id: ingredientId, name: ingredientName },
      bubbles: true
    }))
  }

  handleKeydown(event) {
    if (!this.isOpen) {
      if (event.key === 'ArrowDown' || event.key === 'Enter') {
        this.showOptions()
        event.preventDefault()
      }
      return
    }

    switch (event.key) {
      case 'ArrowDown':
        event.preventDefault()
        this.selectedIndex = Math.min(this.selectedIndex + 1, this.filteredIngredients.length - 1)
        this.renderOptions()
        break
        
      case 'ArrowUp':
        event.preventDefault()
        this.selectedIndex = Math.max(this.selectedIndex - 1, -1)
        this.renderOptions()
        break
        
      case 'Enter':
        event.preventDefault()
        if (this.selectedIndex >= 0 && this.filteredIngredients[this.selectedIndex]) {
          const ingredient = this.filteredIngredients[this.selectedIndex]
          this.inputTarget.value = ingredient.name
          this.hiddenFieldTarget.value = ingredient.id
          this.hideOptions()
          
          // Trigger change event
          const changeEvent = new Event('change', { bubbles: true })
          this.hiddenFieldTarget.dispatchEvent(changeEvent)
          
          // Notify parent controller
          this.element.dispatchEvent(new CustomEvent('ingredient:selected', {
            detail: { id: ingredient.id, name: ingredient.name },
            bubbles: true
          }))
        }
        break
        
      case 'Escape':
        this.hideOptions()
        break
    }
  }

  handleClickOutside(event) {
    if (!this.element.contains(event.target) && !this.optionsTarget.contains(event.target)) {
      this.hideOptions()
    }
  }

  handleScroll() {
    if (this.isOpen) {
      this.positionDropdown()
    }
  }

  handleResize() {
    if (this.isOpen) {
      this.positionDropdown()
    }
  }

  setSelectedIngredient(ingredientId) {
    const ingredient = this.ingredients.find(i => i.id == ingredientId)
    if (ingredient) {
      this.inputTarget.value = ingredient.name
      this.hiddenFieldTarget.value = ingredient.id
    }
  }
}
