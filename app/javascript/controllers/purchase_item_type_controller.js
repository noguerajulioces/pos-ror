import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["productSelect", "ingredientSelect", "typeSelect"]

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
}
