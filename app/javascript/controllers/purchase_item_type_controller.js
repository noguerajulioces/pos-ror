import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["productSelect", "ingredientSelect", "typeSelect", "unitSelect"]

  connect() {
    this.toggleSelects()
    
    // Listen for custom events from search components
    this.element.addEventListener('product:selected', this.handleProductSelected.bind(this))
    this.element.addEventListener('ingredient:selected', this.handleIngredientSelected.bind(this))
  }

  toggleSelects(event) {
    const type = event ? event.target.value : this.typeSelectTarget.value
    
    if (type === 'Product') {
      this.showProductSelect()
      this.hideIngredientSelect()
    } else if (type === 'Ingredient') {
      this.hideProductSelect()
      this.showIngredientSelect()
    } else {
      this.hideProductSelect()
      this.hideIngredientSelect()
    }
  }

  showProductSelect() {
    if (this.hasProductSelectTarget) {
      this.productSelectTarget.style.display = 'block'
      const selectElement = this.productSelectTarget.querySelector('select')
      const hiddenField = this.productSelectTarget.querySelector('input[type="hidden"]')
      
      if (selectElement) {
        selectElement.disabled = false
        selectElement.name = selectElement.name.replace('_destroy', '').replace('[_destroy]', '')
      }
      
      if (hiddenField) {
        hiddenField.disabled = false
      }
    }
  }

  hideProductSelect() {
    if (this.hasProductSelectTarget) {
      this.productSelectTarget.style.display = 'none'
      const selectElement = this.productSelectTarget.querySelector('select')
      const hiddenField = this.productSelectTarget.querySelector('input[type="hidden"]')
      const textInput = this.productSelectTarget.querySelector('input[type="text"]')
      
      if (selectElement) {
        selectElement.disabled = true
        selectElement.value = ''
      }
      
      if (hiddenField) {
        hiddenField.disabled = true
        hiddenField.value = ''
      }
      
      if (textInput) {
        textInput.value = ''
      }
    }
  }

  showIngredientSelect() {
    if (this.hasIngredientSelectTarget) {
      this.ingredientSelectTarget.style.display = 'block'
      const selectElement = this.ingredientSelectTarget.querySelector('select')
      const hiddenField = this.ingredientSelectTarget.querySelector('input[type="hidden"]')
      
      if (selectElement) {
        selectElement.disabled = false
        selectElement.name = selectElement.name.replace('_destroy', '').replace('[_destroy]', '')
      }
      
      if (hiddenField) {
        hiddenField.disabled = false
      }
    }
  }

  hideIngredientSelect() {
    if (this.hasIngredientSelectTarget) {
      this.ingredientSelectTarget.style.display = 'none'
      const selectElement = this.ingredientSelectTarget.querySelector('select')
      const hiddenField = this.ingredientSelectTarget.querySelector('input[type="hidden"]')
      const textInput = this.ingredientSelectTarget.querySelector('input[type="text"]')
      
      if (selectElement) {
        selectElement.disabled = true
        selectElement.value = ''
      }
      
      if (hiddenField) {
        hiddenField.disabled = true
        hiddenField.value = ''
      }
      
      if (textInput) {
        textInput.value = ''
      }
    }
  }

  // Handle product selection and autocomplete unit
  productSelected(event) {
    const productId = event.target.value
    if (productId && this.hasUnitSelectTarget) {
      this.fetchProductUnit(productId)
    }
  }

  // Handle ingredient selection and autocomplete unit
  ingredientSelected(event) {
    const ingredientId = event.target.value
    if (ingredientId && this.hasUnitSelectTarget) {
      this.fetchIngredientUnit(ingredientId)
    }
  }

  // Fetch product unit via AJAX
  async fetchProductUnit(productId) {
    try {
      const response = await fetch(`/products/${productId}/unit`, {
        headers: {
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest'
        }
      })
      
      if (response.ok) {
        const data = await response.json()
        this.setUnitValue(data.unit_id)
      }
    } catch (error) {
      console.error('Error fetching product unit:', error)
    }
  }

  // Fetch ingredient unit via AJAX
  async fetchIngredientUnit(ingredientId) {
    try {
      const response = await fetch(`/ingredients/${ingredientId}/unit`, {
        headers: {
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest'
        }
      })
      
      if (response.ok) {
        const data = await response.json()
        this.setUnitValue(data.unit_id)
      }
    } catch (error) {
      console.error('Error fetching ingredient unit:', error)
    }
  }

  // Set the unit select value
  setUnitValue(unitId) {
    const unitSelect = this.unitSelectTarget.querySelector('select')
    if (unitSelect && unitId) {
      unitSelect.value = unitId
    }
  }

  // Handle product selection from search component
  handleProductSelected(event) {
    const productId = event.detail.id
    if (productId && this.hasUnitSelectTarget) {
      this.fetchProductUnit(productId)
    }
  }

  // Handle ingredient selection from search component
  handleIngredientSelected(event) {
    const ingredientId = event.detail.id
    if (ingredientId && this.hasUnitSelectTarget) {
      this.fetchIngredientUnit(ingredientId)
    }
  }
}
