import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="number-format"
export default class extends Controller {
  static targets = ["input"]

  connect() {
    this.inputTarget.addEventListener('input', this.formatNumber.bind(this))
  }

  formatNumber(e) {
    let value = e.target.value
    
    // Allow only digits (no decimals for Guaraníes)
    value = value.replace(/\D/g, '')
    
    // Add thousand separators (dots)
    value = value.replace(/\B(?=(\d{3})+(?!\d))/g, ".")
    
    e.target.value = value
  }
}
