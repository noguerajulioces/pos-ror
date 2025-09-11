import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="recipe-component"
export default class extends Controller {
  edit(event) {
    const componentId = event.target.dataset.componentId
    const editForm = document.getElementById(`edit-form-${componentId}`)
    
    if (editForm) {
      editForm.classList.toggle('hidden')
    }
  }

  cancelEdit(event) {
    const componentId = event.target.dataset.componentId
    const editForm = document.getElementById(`edit-form-${componentId}`)
    
    if (editForm) {
      editForm.classList.add('hidden')
    }
  }
}
