import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["search", "create"]

  connect() {
    console.log("Tabs controller connected")
    this.showActiveTab()
  }

  switch(event) {
    // Get all tab buttons
    const tabButtons = document.querySelectorAll('[data-controller="tabs"]')
    
    // Remove active class from all tabs
    tabButtons.forEach(tab => {
      tab.classList.remove("border-indigo-500", "text-indigo-600")
      tab.classList.add("border-transparent", "text-gray-500", "hover:text-gray-700", "hover:border-gray-300")
      tab.dataset.tabsActive = "false"
    })
    
    // Add active class to clicked tab
    event.currentTarget.classList.remove("border-transparent", "text-gray-500", "hover:text-gray-700", "hover:border-gray-300")
    event.currentTarget.classList.add("border-indigo-500", "text-indigo-600")
    event.currentTarget.dataset.tabsActive = "true"
    
    this.showActiveTab()
  }

  showActiveTab() {
    // Hide all tab contents
    const tabContents = document.querySelectorAll('.tab-content')
    tabContents.forEach(content => {
      content.classList.add('hidden')
    })
    
    // Show active tab content
    const activeTab = document.querySelector('[data-controller="tabs"][data-tabs-active="true"]')
    if (activeTab) {
      const targetId = `tab-${activeTab.dataset.tabsTarget}`
      const targetContent = document.getElementById(targetId)
      if (targetContent) {
        targetContent.classList.remove('hidden')
      }
    }
  }
}