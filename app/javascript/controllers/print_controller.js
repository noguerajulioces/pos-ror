import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String }

  print(event) {
    event.preventDefault()
    
    const url = this.urlValue || event.currentTarget.href
    if (!url) return

    // Create a hidden iframe
    const iframe = document.createElement('iframe')
    iframe.style.position = 'fixed'
    iframe.style.right = '0'
    iframe.style.bottom = '0'
    iframe.style.width = '0'
    iframe.style.height = '0'
    iframe.style.border = '0'
    iframe.src = url
    
    document.body.appendChild(iframe)
    
    iframe.onload = () => {
      try {
        // Wait a bit for styles/images to load inside the iframe
        setTimeout(() => {
          iframe.contentWindow.focus()
          iframe.contentWindow.print()
          
          // Remove iframe after a delay to ensure print dialog has opened
          setTimeout(() => {
            document.body.removeChild(iframe)
          }, 60000) 
        }, 500)
      } catch (e) {
        console.error("Error printing:", e)
      }
    }
  }
}
