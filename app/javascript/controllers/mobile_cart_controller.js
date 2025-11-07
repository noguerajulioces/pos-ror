import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["bottomSheet", "overlay", "sheet", "fab", "badge", "badgeCount"]
  
  connect() {
    this.isOpen = false
    this.touchStartY = 0
    this.touchStartTime = 0
    this.currentTranslateY = 0
    
    // Ensure bottom sheet is closed on initial load
    this.close()
    
    // Update badge on initial load
    this.updateBadge()
    
    // Listen for cart updates (via Turbo Stream or custom events)
    this.boundUpdateBadge = this.updateBadge.bind(this)
    
    // Listen to Turbo Stream updates
    document.addEventListener('turbo:frame-load', this.boundUpdateBadge)
    document.addEventListener('turbo:before-stream-render', this.boundUpdateBadge)
    document.addEventListener('turbo:after-stream-render', this.boundUpdateBadge)
    document.addEventListener('cart:updated', this.boundUpdateBadge)
    
    // Observe changes to cart-items-body (MutationObserver)
    this.setupCartObserver()
    
    // Also check periodically (fallback)
    this.badgeInterval = setInterval(() => this.updateBadge(), 2000)
  }
  
  disconnect() {
    document.removeEventListener('turbo:frame-load', this.boundUpdateBadge)
    document.removeEventListener('turbo:before-stream-render', this.boundUpdateBadge)
    document.removeEventListener('turbo:after-stream-render', this.boundUpdateBadge)
    document.removeEventListener('cart:updated', this.boundUpdateBadge)
    
    if (this.badgeInterval) {
      clearInterval(this.badgeInterval)
    }
    
    if (this.cartObserver) {
      this.cartObserver.disconnect()
    }
  }
  
  setupCartObserver() {
    const cartItemsBody = document.getElementById('cart-items-body')
    if (!cartItemsBody) return
    
    this.cartObserver = new MutationObserver(() => {
      // Debounce updates
      clearTimeout(this.updateTimeout)
      this.updateTimeout = setTimeout(() => this.updateBadge(), 100)
    })
    
    this.cartObserver.observe(cartItemsBody, {
      childList: true,
      subtree: true
    })
  }
  
  toggle() {
    if (this.isOpen) {
      this.close()
    } else {
      this.open()
    }
  }
  
  open() {
    this.isOpen = true
    this.sheetTarget.style.transform = 'translateY(0)'
    
    // Enable pointer events on bottomSheet
    this.bottomSheetTarget.classList.remove('pointer-events-none')
    this.bottomSheetTarget.style.pointerEvents = 'auto'
    
    // Show overlay with pointer events
    this.overlayTarget.classList.remove('opacity-0', 'pointer-events-none')
    this.overlayTarget.classList.add('opacity-100', 'pointer-events-auto')
    this.overlayTarget.style.opacity = ''
    this.overlayTarget.style.pointerEvents = 'auto'
    
    // Hide FAB when bottom sheet is open
    this.fabTarget.style.transform = 'scale(0)'
    this.fabTarget.style.opacity = '0'
    document.body.style.overflow = 'hidden'
  }
  
  close() {
    this.isOpen = false
    this.sheetTarget.style.transform = 'translateY(100%)'
    
    // Force pointer-events-none on bottomSheet
    this.bottomSheetTarget.classList.add('pointer-events-none')
    this.bottomSheetTarget.style.pointerEvents = 'none'
    
    // Clean up overlay: remove inline styles and ensure pointer-events-none
    this.overlayTarget.classList.remove('opacity-100', 'pointer-events-auto')
    this.overlayTarget.classList.add('opacity-0', 'pointer-events-none')
    this.overlayTarget.style.opacity = ''
    this.overlayTarget.style.pointerEvents = 'none'
    
    // Show FAB when bottom sheet is closed
    this.fabTarget.style.transform = 'scale(1)'
    this.fabTarget.style.opacity = '1'
    
    // Restore body scroll
    document.body.style.overflow = ''
    
    // Double-check after transition completes (300ms)
    setTimeout(() => {
      this.bottomSheetTarget.classList.add('pointer-events-none')
      this.bottomSheetTarget.style.pointerEvents = 'none'
      this.overlayTarget.classList.add('pointer-events-none')
      this.overlayTarget.style.pointerEvents = 'none'
      this.overlayTarget.style.opacity = ''
    }, 350)
  }
  
  // Swipe gesture handlers
  handleTouchStart(event) {
    this.touchStartY = event.touches[0].clientY
    this.touchStartTime = Date.now()
    this.currentTranslateY = this.getCurrentTranslateY()
  }
  
  handleTouchMove(event) {
    if (!this.isOpen) return
    
    const currentY = event.touches[0].clientY
    const deltaY = currentY - this.touchStartY
    
    // Only allow downward swipes
    if (deltaY > 0) {
      const translateY = Math.min(deltaY, 0)
      this.sheetTarget.style.transform = `translateY(${translateY}px)`
      
      // Update overlay opacity based on drag distance
      const maxHeight = window.innerHeight * 0.85
      const opacity = 1 - (Math.abs(translateY) / maxHeight)
      this.overlayTarget.style.opacity = opacity
    }
  }
  
  handleTouchEnd(event) {
    if (!this.isOpen) return
    
    const currentY = event.changedTouches[0].clientY
    const deltaY = currentY - this.touchStartY
    const deltaTime = Date.now() - this.touchStartTime
    const velocity = Math.abs(deltaY) / deltaTime
    
    // Close if swiped down more than 100px or with high velocity
    if (deltaY > 100 || (deltaY > 50 && velocity > 0.5)) {
      this.close()
    } else {
      // Snap back to open position
      this.sheetTarget.style.transform = 'translateY(0)'
      // Use class-based opacity instead of inline style for consistency
      this.overlayTarget.classList.remove('opacity-0')
      this.overlayTarget.classList.add('opacity-100')
      this.overlayTarget.style.opacity = ''
    }
  }
  
  getCurrentTranslateY() {
    const transform = window.getComputedStyle(this.sheetTarget).transform
    if (transform === 'none') return 0
    const matrix = transform.match(/matrix.*\((.+)\)/)[1].split(', ')
    return parseFloat(matrix[5]) || 0
  }
  
  updateBadge() {
    // Get cart items count from the DOM
    const cartItemsBody = document.getElementById('cart-items-body')
    if (!cartItemsBody) {
      this.hideBadge()
      return
    }
    
    const cartRows = cartItemsBody.querySelectorAll('tr')
    let itemCount = 0
    
    // Count items (skip empty cart row)
    cartRows.forEach(row => {
      const isEmptyRow = row.querySelector('td[colspan]')
      if (!isEmptyRow) {
        itemCount++
      }
    })
    
    if (itemCount > 0) {
      this.badgeCountTarget.textContent = itemCount > 99 ? '99+' : itemCount
      this.badgeTarget.style.display = 'flex'
    } else {
      this.hideBadge()
    }
  }
  
  hideBadge() {
    this.badgeTarget.style.display = 'none'
  }
}

