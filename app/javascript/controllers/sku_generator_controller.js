import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["nameField", "skuField"]
  static values = { prefix: String }

  generateSku() {
    const name = this.nameFieldTarget.value.trim()
    
    if (name === '') {
      const itemType = this.getItemType()
      alert(`Por favor, ingresa el nombre ${itemType} primero.`)
      this.nameFieldTarget.focus()
      return
    }

    // Generar SKU basado en el nombre
    let sku = this.prefixValue + '-' + name
      .toUpperCase()
      .replace(/[ÁÀÄÂ]/g, 'A')
      .replace(/[ÉÈËÊ]/g, 'E')
      .replace(/[ÍÌÏÎ]/g, 'I')
      .replace(/[ÓÒÖÔ]/g, 'O')
      .replace(/[ÚÙÜÛ]/g, 'U')
      .replace(/Ñ/g, 'N')
      .replace(/[^A-Z0-9\s]/g, '') // Remover caracteres especiales
      .replace(/\s+/g, '-') // Reemplazar espacios con guiones
      .substring(0, this.getMaxLength()) // Limitar longitud

    // Agregar timestamp para unicidad
    const timestamp = Date.now().toString().slice(-4)
    sku += '-' + timestamp

    this.skuFieldTarget.value = sku
    
    // Feedback visual
    this.skuFieldTarget.classList.add('ring-2', 'ring-green-500')
    setTimeout(() => {
      this.skuFieldTarget.classList.remove('ring-2', 'ring-green-500')
    }, 1000)
  }

  getItemType() {
    switch(this.prefixValue) {
      case 'PROD': return 'del producto'
      case 'RECIPE': return 'de la receta'
      case 'COMBO': return 'del combo'
      default: return 'del item'
    }
  }

  getMaxLength() {
    switch(this.prefixValue) {
      case 'PROD': return 10
      case 'RECIPE': return 8
      case 'COMBO': return 12
      default: return 8
    }
  }
}
