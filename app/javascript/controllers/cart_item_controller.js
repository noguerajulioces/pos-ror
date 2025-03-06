import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    productId: Number
  }

  connect() {
    console.log("Cart item controller connected for product ID:", this.productIdValue);
  }

  remove() {
    console.log("Removing product ID:", this.productIdValue);
    
    // Get CSRF token
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content;
    
    // Send request to remove item from cart
    fetch('/pos/remove_from_cart', {
      method: 'DELETE',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken,
        'Accept': 'text/vnd.turbo-stream.html'
      },
      body: JSON.stringify({
        product_id: this.productIdValue
      })
    })
    .then(response => {
      if (!response.ok) {
        throw new Error('Network response was not ok');
      }
      return response.text();
    })
    .then(html => {
      console.log('Product removed from cart successfully');
      
      // Process the Turbo Stream response manually if needed
      if (html.includes('turbo-stream')) {
        const template = document.createElement('template');
        template.innerHTML = html;
        const streamElement = template.content.querySelector('turbo-stream');
        
        if (streamElement) {
          // Apply the stream manually
          document.body.appendChild(streamElement);
        }
      }
    })
    .catch(error => {
      console.error('Error removing product from cart:', error);
    });
  }
}