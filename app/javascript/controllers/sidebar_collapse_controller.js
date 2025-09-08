import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sidebar", "content", "toggleButton", "mainContent"]
  static values = { collapsed: Boolean }

  connect() {
    // Check if sidebar was previously collapsed
    const isCollapsed = localStorage.getItem('sidebar-collapsed') === 'true'
    this.collapsedValue = isCollapsed
    this.updateSidebar()
  }

  toggle() {
    this.collapsedValue = !this.collapsedValue
    this.updateSidebar()
    // Save preference to localStorage
    localStorage.setItem('sidebar-collapsed', this.collapsedValue.toString())
  }

  updateSidebar() {
    if (this.collapsedValue) {
      this.collapseSidebar()
    } else {
      this.expandSidebar()
    }
  }

  collapseSidebar() {
    // Collapse sidebar to icon-only mode
    this.sidebarTarget.classList.remove('lg:w-72')
    this.sidebarTarget.classList.add('lg:w-16')
    
    // Hide text content - be more aggressive about hiding text
    this.contentTargets.forEach(content => {
      content.style.display = 'none'
    })
    
    // Hide all text elements in the sidebar except the toggle button
    const allElements = this.sidebarTarget.querySelectorAll('*')
    allElements.forEach(element => {
      // Skip SVG elements and their children
      if (element.tagName === 'SVG' || element.closest('svg')) {
        return
      }
      
      // Skip the toggle button
      if (element.closest('[data-sidebar-collapse-target="toggleButton"]')) {
        return
      }
      
      // Hide text content
      if (element.textContent && element.textContent.trim() && !element.querySelector('svg')) {
        element.style.display = 'none'
      }
    })
    
    // Adjust main content padding using CSS classes
    if (this.hasMainContentTarget) {
      this.mainContentTarget.classList.remove('lg:pl-72', 'main-content-expanded')
      this.mainContentTarget.classList.add('lg:pl-16', 'main-content-collapsed')
    }
    
    // Update toggle button icon
    this.updateToggleButton(true)
    
    // Add collapsed class for additional styling
    this.sidebarTarget.classList.add('sidebar-collapsed')
  }

  expandSidebar() {
    // Expand sidebar to full width
    this.sidebarTarget.classList.remove('lg:w-16')
    this.sidebarTarget.classList.add('lg:w-72')
    
    // Show text content
    this.contentTargets.forEach(content => {
      content.style.display = ''
    })
    
    // Show all text elements in the sidebar
    const allElements = this.sidebarTarget.querySelectorAll('*')
    allElements.forEach(element => {
      // Skip SVG elements and their children
      if (element.tagName === 'SVG' || element.closest('svg')) {
        return
      }
      
      // Skip the toggle button
      if (element.closest('[data-sidebar-collapse-target="toggleButton"]')) {
        return
      }
      
      // Show text content
      if (element.textContent && element.textContent.trim() && !element.querySelector('svg')) {
        element.style.display = ''
      }
    })
    
    // Adjust main content padding using CSS classes
    if (this.hasMainContentTarget) {
      this.mainContentTarget.classList.remove('lg:pl-16', 'main-content-collapsed')
      this.mainContentTarget.classList.add('lg:pl-72', 'main-content-expanded')
    }
    
    // Update toggle button icon
    this.updateToggleButton(false)
    
    // Remove collapsed class
    this.sidebarTarget.classList.remove('sidebar-collapsed')
  }

  updateToggleButton(isCollapsed) {
    if (this.hasToggleButtonTarget) {
      const icon = this.toggleButtonTarget.querySelector('svg')
      if (icon) {
        if (isCollapsed) {
          // Show expand icon (chevron right)
          icon.innerHTML = `
            <path stroke-linecap="round" stroke-linejoin="round" d="M8.25 4.5l7.5 7.5-7.5 7.5" />
          `
        } else {
          // Show collapse icon (chevron left)
          icon.innerHTML = `
            <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 19.5L8.25 12l7.5-7.5" />
          `
        }
      }
    }
  }
}
