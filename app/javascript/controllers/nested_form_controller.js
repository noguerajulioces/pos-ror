import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "item", "template"]

  connect() {
    // Inicializar el contador de índices si no existe
    if (!this.index) {
      this.index = 0
    }
  }

  addItem(event) {
    event.preventDefault()
    
    // Crear un nuevo elemento basado en el template
    const template = this.templateTarget
    const newItem = template.content.cloneNode(true)
    
    // Actualizar los índices en el nuevo elemento
    this.updateIndexes(newItem, this.index)
    
    // Agregar el nuevo elemento al contenedor
    this.containerTarget.appendChild(newItem)
    
    // Incrementar el índice para el siguiente elemento
    this.index++
  }

  removeItem(event) {
    event.preventDefault()
    
    const item = event.target.closest('[data-nested-form-target="item"]')
    if (item) {
      // Marcar el elemento para eliminación
      const destroyField = item.querySelector('input[name*="[_destroy]"]')
      if (destroyField) {
        destroyField.value = "1"
        item.style.display = "none"
      } else {
        // Si no hay campo _destroy, eliminar directamente
        item.remove()
      }
    }
  }

  updateIndexes(element, index) {
    // Actualizar todos los atributos name que contengan índices
    const inputs = element.querySelectorAll('input, select, textarea')
    inputs.forEach(input => {
      if (input.name) {
        input.name = input.name.replace(/\[\d+\]/, `[${index}]`)
      }
      if (input.id) {
        input.id = input.id.replace(/_\d+/, `_${index}`)
      }
    })

    // Actualizar labels que apunten a los inputs
    const labels = element.querySelectorAll('label')
    labels.forEach(label => {
      if (label.htmlFor) {
        label.htmlFor = label.htmlFor.replace(/_\d+/, `_${index}`)
      }
    })
  }
}
