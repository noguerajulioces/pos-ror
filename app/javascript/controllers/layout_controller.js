import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["leftColumn", "rightColumn", "toggleIcon", "toggleButton"]
  
  connect() {
    // Check localStorage for saved state
    const savedState = localStorage.getItem('rightColumnVisible')
    
    // Initialize with saved state or default to true if no saved state
    this.rightColumnVisible = savedState !== null ? savedState === 'true' : true
    
    this.updateLayout()
    
    // Add longer transition duration to both columns
    this.leftColumnTarget.classList.remove("duration-300")
    this.leftColumnTarget.classList.add("duration-500")
    
    this.rightColumnTarget.classList.remove("duration-300")
    this.rightColumnTarget.classList.add("duration-500")
  }
  
  toggleRightColumn() {
    this.rightColumnVisible = !this.rightColumnVisible
    
    // Save state to localStorage
    localStorage.setItem('rightColumnVisible', this.rightColumnVisible)
    
    this.updateLayout()
  }
  
  updateLayout() {
    if (this.rightColumnVisible) {
      // Show right column
      this.leftColumnTarget.classList.remove("w-full", "pr-6", "shadow-none")
      this.leftColumnTarget.classList.add("w-2/4")
      
      this.rightColumnTarget.classList.remove("w-0", "opacity-0", "p-0", "hidden", "shadow-none")
      this.rightColumnTarget.classList.add("w-2/4", "opacity-100", "p-4", "shadow-md")
      
      // Adjust toggle button position when right column is visible
      if (this.hasToggleButtonTarget) {
        this.toggleButtonTarget.classList.remove("right-8")
        this.toggleButtonTarget.classList.add("-right-4")
      }
      
      // When right column is visible, show right-pointing arrow (to hide it)
      this.toggleIconTarget.innerHTML = '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"></path>';
    } else {
      // Hide right column
      this.leftColumnTarget.classList.remove("w-2/4")
      this.leftColumnTarget.classList.add("w-full", "pr-6", "shadow-md")
      
      this.rightColumnTarget.classList.remove("w-2/4", "opacity-100", "p-4", "shadow-md")
      this.rightColumnTarget.classList.add("w-0", "opacity-0", "p-0", "hidden", "shadow-none")
      
      // Adjust toggle button position when right column is hidden
      if (this.hasToggleButtonTarget) {
        this.toggleButtonTarget.classList.remove("-right-4")
        this.toggleButtonTarget.classList.add("right-8")
      }
      
      // When right column is hidden, show left-pointing arrow (to show it)
      this.toggleIconTarget.innerHTML = '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"></path>';
    }
  }
}