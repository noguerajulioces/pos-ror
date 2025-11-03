import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "template", "addButton"]
  static values = { 
    index: Number
  }

  connect() {
  }

  addIngredient() {
    const newComponent = this.templateTarget.content.cloneNode(true)
    const html = newComponent.querySelector('div').outerHTML.replace(/__INDEX__/g, this.indexValue)
    this.containerTarget.insertAdjacentHTML('beforeend', html)
    this.indexValue++
  }

  removeIngredient(event) {
    // Check if the click is on the remove button
    const removeBtn = event.target.closest('.remove-ingredient-btn')
    if (removeBtn) {
      event.preventDefault()
      const componentDiv = removeBtn.closest('.recipe-component-item')
      if (componentDiv) {
        if (this.containerTarget.children.length > 1) {
          componentDiv.remove()
        } else {
          alert('Debe haber al menos un ingrediente en la receta.')
        }
      }
    }
  }
}
