import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  close() {
    // Update the modal frame with empty content to close it
    const modalFrame = document.getElementById('modal')
    if (modalFrame) {
      modalFrame.innerHTML = ''
    }
  }
}
