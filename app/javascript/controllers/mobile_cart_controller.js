import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["bottomSheet", "overlay", "sheet", "badgeCount2"]
  
  connect() {
    console.log('Mobile cart controller connected')
    this.isOpen = false
    this.touchStartY = 0
    this.touchStartTime = 0
    this.currentTranslateY = 0
    
    // Ensure bottom sheet is closed on initial load
    this.close()
    
    // Update badge on initial load
    console.log('Initial badge update')
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
    this.badgeInterval = setInterval(() => {
      console.log('Periodic badge update')
      this.updateBadge()
    }, 2000)
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
    
    // Enable pointer events on bottomSheet first
    this.bottomSheetTarget.classList.remove('pointer-events-none')
    this.bottomSheetTarget.style.pointerEvents = 'auto'
    
    // Show overlay with pointer events (smooth transition)
    this.overlayTarget.classList.remove('opacity-0', 'pointer-events-none')
    this.overlayTarget.classList.add('opacity-100', 'pointer-events-auto')
    this.overlayTarget.style.opacity = ''
    this.overlayTarget.style.pointerEvents = 'auto'
    
    // Animate sheet up with smooth transition
    requestAnimationFrame(() => {
      this.sheetTarget.style.transition = 'transform 0.4s cubic-bezier(0.32, 0.72, 0, 1)'
      this.sheetTarget.style.transform = 'translateY(0)'
    })
    
    // FAB removed - using bottom bar instead
    
    document.body.style.overflow = 'hidden'
  }
  
  close() {
    this.isOpen = false
    
    // Animate sheet down with smooth transition
    requestAnimationFrame(() => {
      this.sheetTarget.style.transition = 'transform 0.4s cubic-bezier(0.32, 0.72, 0, 1)'
      this.sheetTarget.style.transform = 'translateY(100%)'
    })
    
    // Hide overlay with smooth transition
    this.overlayTarget.classList.remove('opacity-100', 'pointer-events-auto')
    this.overlayTarget.classList.add('opacity-0', 'pointer-events-none')
    this.overlayTarget.style.opacity = ''
    this.overlayTarget.style.pointerEvents = 'none'
    
    // FAB removed - using bottom bar instead
    
    // Restore body scroll
    document.body.style.overflow = ''
    
    // Clean up after transition completes (400ms + buffer)
    setTimeout(() => {
      // Force pointer-events-none on bottomSheet
      this.bottomSheetTarget.classList.add('pointer-events-none')
      this.bottomSheetTarget.style.pointerEvents = 'none'
      
      // Ensure overlay is fully disabled
      this.overlayTarget.classList.add('pointer-events-none')
      this.overlayTarget.style.pointerEvents = 'none'
      this.overlayTarget.style.opacity = ''
    }, 450)
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
      // Disable transition during drag for immediate response
      this.sheetTarget.style.transition = 'none'
      
      // Apply resistance when dragging down (rubber band effect)
      const resistance = 0.5 // Makes it harder to drag as you go down
      const translateY = deltaY * resistance
      this.sheetTarget.style.transform = `translateY(${translateY}px)`
      
      // Update overlay opacity based on drag distance (smooth fade)
      const maxHeight = window.innerHeight * 0.85
      const dragProgress = Math.min(Math.abs(translateY) / maxHeight, 1)
      const opacity = 1 - dragProgress
      this.overlayTarget.style.opacity = opacity
      this.overlayTarget.style.transition = 'none' // Disable transition during drag
    }
  }
  
  handleTouchEnd(event) {
    if (!this.isOpen) return
    
    const currentY = event.changedTouches[0].clientY
    const deltaY = currentY - this.touchStartY
    const deltaTime = Date.now() - this.touchStartTime
    const velocity = deltaTime > 0 ? Math.abs(deltaY) / deltaTime : 0
    
    // Re-enable transitions for smooth snap-back or close
    this.sheetTarget.style.transition = 'transform 0.4s cubic-bezier(0.32, 0.72, 0, 1)'
    this.overlayTarget.style.transition = 'opacity 0.4s ease-in-out'
    
    // Close if swiped down more than 120px or with high velocity (>0.3)
    // Adjusted thresholds for better UX
    if (deltaY > 120 || (deltaY > 60 && velocity > 0.3)) {
      this.close()
    } else {
      // Snap back to open position with smooth spring-like animation
      this.sheetTarget.style.transform = 'translateY(0)'
      
      // Restore overlay opacity smoothly
      this.overlayTarget.style.opacity = '1'
      this.overlayTarget.classList.remove('opacity-0')
      this.overlayTarget.classList.add('opacity-100')
    }
  }
  
  getCurrentTranslateY() {
    const transform = window.getComputedStyle(this.sheetTarget).transform
    if (transform === 'none') return 0
    const matrix = transform.match(/matrix.*\((.+)\)/)[1].split(', ')
    return parseFloat(matrix[5]) || 0
  }
  
  updateBadge() {
    console.log('updateBadge called')
    
    // Try to get item count from session cart directly
    let itemCount = 0
    
    // Check mobile cart (divs)
    const cartItemsBody = document.getElementById('cart-items-body')
    if (cartItemsBody) {
      // In mobile, each cart item is a div with class 'p-4'
      const cartDivs = cartItemsBody.querySelectorAll('div.p-4')
      itemCount = cartDivs.length
      console.log('Mobile cart items found:', itemCount)
    } else {
      // Check desktop cart (table rows)
      const cartItemsBodyDesktop = document.getElementById('cart-items-body-desktop')
      if (cartItemsBodyDesktop) {
        const cartRows = cartItemsBodyDesktop.querySelectorAll('tr')
        // Count items (skip empty cart row)
        cartRows.forEach(row => {
          const isEmptyRow = row.querySelector('td[colspan]')
          if (!isEmptyRow) {
            itemCount++
          }
        })
        console.log('Desktop cart items found:', itemCount)
      } else {
        console.log('No cart-items-body found (mobile or desktop)')
      }
    }
    
    console.log('Final item count:', itemCount)
    const displayCount = itemCount > 99 ? '99+' : itemCount.toString()
    
    // Update bottom bar badge
    if (this.hasBadgeCount2Target) {
      console.log('Updating badge to:', displayCount)
      this.badgeCount2Target.textContent = displayCount
    } else {
      console.log('badgeCount2Target not found')
    }
  }
}

