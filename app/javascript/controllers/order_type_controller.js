import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    orderType: String
  }

  select(event) {
    event.preventDefault()
    
    // Obtener el tipo de pedido seleccionado
    const orderType = this.orderTypeValue
    
    // Actualizar el texto del enlace
    const orderTypeElement = document.getElementById("order_type")
    if (orderTypeElement) {
      orderTypeElement.textContent = orderType
    }
    
    // Cerrar el modal
    const modal = this.element.closest('.fixed')
    if (modal) {
      modal.remove()
    }
  }
}