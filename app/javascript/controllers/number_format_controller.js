import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="number-format"
export default class extends Controller {
  static targets = ["input"]

  connect() {
    this.inputTarget.addEventListener('input', this.formatNumber.bind(this))
  }

  formatNumber(e) {
    // Remueve caracteres que no sean dígitos
    let value = e.target.value.replace(/\D/g, '')
    // Agrega puntos como separadores de miles
    value = value.replace(/\B(?=(\d{3})+(?!\d))/g, ".")
    e.target.value = value
  }
}
