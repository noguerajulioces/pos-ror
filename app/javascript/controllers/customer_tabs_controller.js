import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "content"]

  connect() {
    console.log("Customer tabs controller connected")
    // Ensure the first tab (details) is active by default
    this.showTab("details")
  }

  switchTab(event) {
    const clickedTab = event.currentTarget
    const targetTab = clickedTab.dataset.tab
    
    this.showTab(targetTab)
  }

  showTab(tabName) {
    // Update all tab buttons
    this.tabTargets.forEach(tab => {
      if (tab.dataset.tab === tabName) {
        // Active tab styles
        tab.classList.remove('border-transparent', 'text-gray-500', 'hover:text-gray-700', 'hover:border-gray-300')
        tab.classList.add('border-indigo-500', 'text-indigo-600')
      } else {
        // Inactive tab styles
        tab.classList.remove('border-indigo-500', 'text-indigo-600')
        tab.classList.add('border-transparent', 'text-gray-500', 'hover:text-gray-700', 'hover:border-gray-300')
      }
    })

    // Update all content panels
    this.contentTargets.forEach(content => {
      if (content.dataset.tab === tabName) {
        content.classList.remove('hidden')
      } else {
        content.classList.add('hidden')
      }
    })
  }
}
