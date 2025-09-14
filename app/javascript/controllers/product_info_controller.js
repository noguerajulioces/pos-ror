import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="product-info"
export default class extends Controller {
  static targets = ["selector", "infoContainer", "noProductSelected", "productDetails", 
                   "productPrice", "productStock", "productUnit", "productCategory", 
                   "stockWarning", "noStockWarning", "stockWarningText", "quantityInput"]
  
  connect() {
    console.log("ProductInfoController connected")
    // Inicializar información para productos ya seleccionados
    this.initializeSelectedProducts()
  }

  initializeSelectedProducts() {
    this.selectorTargets.forEach(selector => {
      if (selector.value && selector.value !== '') {
        this.updateProductInfo({ target: selector })
      }
    })
  }

  // Cuando cambia la selección del producto
  updateProductInfo(event) {
    const selector = event.target
    const selectedOption = selector.options[selector.selectedIndex]
    const componentDiv = selector.closest('.combo-component-item')
    const infoContainer = componentDiv.querySelector('[data-product-info-target="infoContainer"]')
    const quantityInput = componentDiv.querySelector('input[type="number"]')
    
    if (!selectedOption || !selectedOption.value || selectedOption.value === '') {
      this.showNoProductSelected(infoContainer)
      return
    }

    // Obtener datos del producto desde data attributes
    const productData = {
      name: selectedOption.dataset.productName,
      price: parseFloat(selectedOption.dataset.productPrice) || 0,
      stock: parseFloat(selectedOption.dataset.productStock) || 0,
      unit: selectedOption.dataset.productUnit,
      category: selectedOption.dataset.productCategory
    }

    const quantity = parseFloat(quantityInput?.value) || 1

    this.showProductDetails(infoContainer, productData, quantity)
  }

  // Cuando cambia la cantidad
  updateQuantity(event) {
    const quantityInput = event.target
    const componentDiv = quantityInput.closest('.combo-component-item')
    const selector = componentDiv.querySelector('.product-selector')
    
    if (selector && selector.value) {
      this.updateProductInfo({ target: selector })
    }
  }

  showNoProductSelected(container) {
    const noProductDiv = container.querySelector('[data-product-info-target="noProductSelected"]')
    const productDetailsDiv = container.querySelector('[data-product-info-target="productDetails"]')
    
    if (noProductDiv) noProductDiv.classList.remove('hidden')
    if (productDetailsDiv) productDetailsDiv.classList.add('hidden')
  }

  showProductDetails(container, productData, quantity) {
    const noProductDiv = container.querySelector('[data-product-info-target="noProductSelected"]')
    const productDetailsDiv = container.querySelector('[data-product-info-target="productDetails"]')
    
    // Mostrar/ocultar contenedores
    if (noProductDiv) noProductDiv.classList.add('hidden')
    if (productDetailsDiv) productDetailsDiv.classList.remove('hidden')

    // Actualizar información del producto
    this.updateProductValues(container, productData)
    this.updateStockAlerts(container, productData, quantity)
    this.updateStockColors(container, productData, quantity)
  }

  updateProductValues(container, productData) {
    const priceElement = container.querySelector('[data-product-info-target="productPrice"]')
    const stockElement = container.querySelector('[data-product-info-target="productStock"]')
    const unitElement = container.querySelector('[data-product-info-target="productUnit"]')
    const categoryElement = container.querySelector('[data-product-info-target="productCategory"]')

    if (priceElement) priceElement.textContent = this.formatCurrency(productData.price)
    if (stockElement) stockElement.textContent = `${this.formatNumber(productData.stock)} ${productData.unit}`
    if (unitElement) unitElement.textContent = productData.unit
    if (categoryElement) categoryElement.textContent = productData.category
  }

  updateStockAlerts(container, productData, quantity) {
    const stockWarning = container.querySelector('[data-product-info-target="stockWarning"]')
    const noStockWarning = container.querySelector('[data-product-info-target="noStockWarning"]')
    const stockWarningText = container.querySelector('[data-product-info-target="stockWarningText"]')

    // Ocultar todas las alertas primero
    if (stockWarning) stockWarning.classList.add('hidden')
    if (noStockWarning) noStockWarning.classList.add('hidden')

    if (productData.stock === 0) {
      if (noStockWarning) noStockWarning.classList.remove('hidden')
    } else if (productData.stock < quantity) {
      if (stockWarning) stockWarning.classList.remove('hidden')
      if (stockWarningText) {
        stockWarningText.textContent = 
          `Stock insuficiente. Necesitas ${quantity} ${productData.unit} pero solo hay ${this.formatNumber(productData.stock)} ${productData.unit} disponibles.`
      }
    }
  }

  updateStockColors(container, productData, quantity) {
    const stockElement = container.querySelector('[data-product-info-target="productStock"]')
    
    if (!stockElement) return

    // Remover clases de color existentes
    stockElement.classList.remove('text-green-600', 'text-yellow-600', 'text-red-600')

    // Aplicar color según disponibilidad
    if (productData.stock === 0) {
      stockElement.classList.add('text-red-600')
    } else if (productData.stock < quantity) {
      stockElement.classList.add('text-yellow-600')
    } else {
      stockElement.classList.add('text-green-600')
    }
  }

  formatCurrency(amount) {
    return new Intl.NumberFormat('es-PY', {
      style: 'currency',
      currency: 'PYG',
      minimumFractionDigits: 0,
      maximumFractionDigits: 0
    }).format(amount).replace('PYG', '₲s.')
  }

  formatNumber(number) {
    return new Intl.NumberFormat('es-PY').format(number)
  }
}
