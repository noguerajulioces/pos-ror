import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["leftColumn", "rightColumn", "toggleIcon"]
  
  connect() {
    // Initialize with right column visible
    this.rightColumnVisible = true
    this.updateLayout()
  }
  
  toggleRightColumn() {
    this.rightColumnVisible = !this.rightColumnVisible
    this.updateLayout()
  }
  
  updateLayout() {
    if (this.rightColumnVisible) {
      // Show right column
      this.leftColumnTarget.classList.remove("w-full")
      this.leftColumnTarget.classList.add("w-2/4")
      
      this.rightColumnTarget.classList.remove("w-0", "opacity-0", "p-0", "hidden")
      this.rightColumnTarget.classList.add("w-2/4", "opacity-100", "p-4")
      
      // Update icon to show "hide" arrow
      this.toggleIconTarget.innerHTML = '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 5l7 7-7 7M5 5l7 7-7 7"></path>'
    } else {
      // Hide right column
      this.leftColumnTarget.classList.remove("w-2/4")
      this.leftColumnTarget.classList.add("w-full")
      
      this.rightColumnTarget.classList.remove("w-2/4", "opacity-100", "p-4")
      this.rightColumnTarget.classList.add("w-0", "opacity-0", "p-0", "hidden")
      
      // Update icon to show "show" arrow
      this.toggleIconTarget.innerHTML = '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 19l-7-7 7-7m8 14l-7-7 7-7"></path>'
    }
  }
}