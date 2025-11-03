import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "hiddenField", "options", "optionsList", "noResults", "toggleButton"]
  static values = { selectedValue: String }

  connect() {
    this.products = []
    this.filteredProducts = []
    this.selectedIndex = -1
    this.isOpen = false
    
    // Load products on connect
    this.loadProducts()
    
    // Set initial value if provided
    if (this.selectedValueValue) {
      this.setSelectedProduct(this.selectedValueValue)
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

  async loadProducts() {
    try {
      const response = await fetch('/pos/search_products?q=&kind_filter=simple', {
        headers: {
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest'
        }
      })
      
      if (response.ok) {
        const data = await response.json()
        this.products = data.products
        this.filteredProducts = this.products
      }
    } catch (error) {
      console.error('Error loading products:', error)
    }
  }

  search(event) {
    const query = event.target.value.toLowerCase().trim()
    
    if (query === '') {
      this.filteredProducts = this.products
    } else {
      this.filteredProducts = this.products.filter(product => 
        product.name.toLowerCase().includes(query) ||
        (product.sku && product.sku.toLowerCase().includes(query))
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
    const inputRect = this.inputTarget.getBoundingClientRect()
    const dropdown = this.optionsTarget
    
    dropdown.style.position = 'fixed'
    dropdown.style.top = `${inputRect.bottom}px`
    dropdown.style.left = `${inputRect.left}px`
    dropdown.style.width = `${Math.max(inputRect.width, 300)}px`
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

  focus() {
    this.showOptions()
  }

  click() {
    this.showOptions()
  }

  renderOptions() {
    if (this.filteredProducts.length === 0) {
      this.optionsListTarget.innerHTML = ''
      this.noResultsTarget.classList.remove('hidden')
      return
    }
    
    this.noResultsTarget.classList.add('hidden')
    
    const optionsHtml = this.filteredProducts.map((product, index) => `
      <div class="block px-3 py-2 text-gray-900 cursor-pointer select-none hover:bg-indigo-600 hover:text-white ${index === this.selectedIndex ? 'bg-indigo-600 text-white' : ''}"
           data-action="click->product-autocomplete#selectProduct"
           data-product-id="${product.id}"
           data-product-name="${product.name}"
           data-index="${index}">
        <div class="flex justify-between items-center">
          <div class="flex-1 min-w-0">
            <div class="font-medium truncate">${product.name}</div>
            ${product.sku ? `<div class="text-xs opacity-75">SKU: ${product.sku}</div>` : ''}
          </div>
          <div class="ml-3 text-xs opacity-75 text-right flex-shrink-0">
            <div>Precio:</div>
            <div class="font-medium">₲s. ${parseInt(product.price).toLocaleString('es-PY')}</div>
          </div>
        </div>
      </div>
    `).join('')
    
    this.optionsListTarget.innerHTML = optionsHtml
  }

  selectProduct(event) {
    const productId = event.currentTarget.dataset.productId
    const productName = event.currentTarget.dataset.productName
    
    this.inputTarget.value = productName
    this.hiddenFieldTarget.value = productId
    this.hideOptions()
    
    // Trigger change event
    const changeEvent = new Event('change', { bubbles: true })
    this.hiddenFieldTarget.dispatchEvent(changeEvent)
    
    // Notify parent controller
    this.element.dispatchEvent(new CustomEvent('product:selected', {
      detail: { id: productId, name: productName },
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
        this.selectedIndex = Math.min(this.selectedIndex + 1, this.filteredProducts.length - 1)
        this.renderOptions()
        break
        
      case 'ArrowUp':
        event.preventDefault()
        this.selectedIndex = Math.max(this.selectedIndex - 1, -1)
        this.renderOptions()
        break
        
      case 'Enter':
        event.preventDefault()
        if (this.selectedIndex >= 0 && this.filteredProducts[this.selectedIndex]) {
          const product = this.filteredProducts[this.selectedIndex]
          this.inputTarget.value = product.name
          this.hiddenFieldTarget.value = product.id
          this.hideOptions()
          
          const changeEvent = new Event('change', { bubbles: true })
          this.hiddenFieldTarget.dispatchEvent(changeEvent)
          
          this.element.dispatchEvent(new CustomEvent('product:selected', {
            detail: { id: product.id, name: product.name },
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

  setSelectedProduct(productId) {
    const product = this.products.find(p => p.id == productId)
    if (product) {
      this.inputTarget.value = product.name
      this.hiddenFieldTarget.value = product.id
    }
  }
}
