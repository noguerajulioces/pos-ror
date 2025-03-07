import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="notification"
export default class extends Controller {
  connect() {
    // Automatically hide notification after 5 seconds
    this.timeout = setTimeout(() => this.close(), 5000)
  }

  close() {
    // Add animation or simply remove the notification
    this.element.remove()
  }

  disconnect() {
    // Clear timer when controller disconnects
    clearTimeout(this.timeout)
  }
}
