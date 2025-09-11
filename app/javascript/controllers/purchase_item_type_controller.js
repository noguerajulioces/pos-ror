import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["productSelect", "ingredientSelect", "typeSelect", "unitSelect"]

  connect() {
    this.toggleSelects()
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
      if (selectElement) {
        selectElement.disabled = false
        selectElement.name = selectElement.name.replace('_destroy', '').replace('[_destroy]', '')
      }
    }
  }

  hideProductSelect() {
    if (this.hasProductSelectTarget) {
      this.productSelectTarget.style.display = 'none'
      const selectElement = this.productSelectTarget.querySelector('select')
      if (selectElement) {
        selectElement.disabled = true
        selectElement.value = ''
      }
    }
  }

  showIngredientSelect() {
    if (this.hasIngredientSelectTarget) {
      this.ingredientSelectTarget.style.display = 'block'
      const selectElement = this.ingredientSelectTarget.querySelector('select')
      if (selectElement) {
        selectElement.disabled = false
        selectElement.name = selectElement.name.replace('_destroy', '').replace('[_destroy]', '')
      }
    }
  }

  hideIngredientSelect() {
    if (this.hasIngredientSelectTarget) {
      this.ingredientSelectTarget.style.display = 'none'
      const selectElement = this.ingredientSelectTarget.querySelector('select')
      if (selectElement) {
        selectElement.disabled = true
        selectElement.value = ''
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
}
