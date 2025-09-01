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
      this.productSelectTarget.disabled = false
    }
  }

  hideProductSelect() {
    if (this.hasProductSelectTarget) {
      this.productSelectTarget.style.display = 'none'
      this.productSelectTarget.disabled = true
      this.productSelectTarget.value = ''
    }
  }

  showIngredientSelect() {
    if (this.hasIngredientSelectTarget) {
      this.ingredientSelectTarget.style.display = 'block'
      this.ingredientSelectTarget.disabled = false
    }
  }

  hideIngredientSelect() {
    if (this.hasIngredientSelectTarget) {
      this.ingredientSelectTarget.style.display = 'none'
      this.ingredientSelectTarget.disabled = true
      this.ingredientSelectTarget.value = ''
    }
  }
}
