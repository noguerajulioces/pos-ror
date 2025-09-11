import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="modal"
export default class extends Controller {
  connect() {
    // Prevent background scroll when modal is open
    document.body.style.overflow = 'hidden'
  }

  disconnect() {
    // Restore background scroll when modal is closed
    document.body.style.overflow = 'auto'
  }

  close(event) {
    // Close modal when clicking outside or on close button
    if (event.target === event.currentTarget || event.target.closest('[data-action*="modal#close"]')) {
      this.element.remove()
    }
  }

  // Close modal with Escape key
  closeWithKeyboard(event) {
    if (event.key === "Escape") {
      this.close(event)
    }
  }
}