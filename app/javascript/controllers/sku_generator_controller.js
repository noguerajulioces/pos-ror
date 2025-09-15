import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["nameField", "skuField"]
  static values = { prefix: String }

  generateSku() {
    const name = this.nameFieldTarget.value.trim()
    
    if (name === '') {
      alert(`Por favor, ingresa el nombre ${this.prefixValue === 'PROD' ? 'del producto' : 'de la receta'} primero.`)
      this.nameFieldTarget.focus()
      return
    }

    // Generar SKU basado en el nombre
    let sku = this.prefixValue + '-' + name
      .toUpperCase()
      .replace(/[^A-Z0-9\s]/g, '') // Remover caracteres especiales
      .replace(/\s+/g, '-') // Reemplazar espacios con guiones
      .substring(0, this.prefixValue === 'PROD' ? 10 : 8) // Limitar longitud

    // Agregar timestamp para unicidad
    const timestamp = Date.now().toString().slice(-4)
    sku += '-' + timestamp

    this.skuFieldTarget.value = sku
  }
}
