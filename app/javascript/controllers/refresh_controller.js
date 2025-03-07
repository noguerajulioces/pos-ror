import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("Refresh controller connected");
  }
  
  reload() {
    console.log("Reloading and clearing cart");
    
    // Get CSRF token
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content;
    
    // Send request to clear cart
    fetch('/pos/clear_cart', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken,
        'Accept': 'text/vnd.turbo-stream.html, application/json'
      }
    })
    .then(response => {
      if (!response.ok) {
        throw new Error('Network response was not ok');
      }
      return response.text();
    })
    .then(html => {
      console.log('Cart cleared successfully');
      window.location.reload();
      
      // Optionally reload the page or reset other elements
      // window.location.reload(); // Uncomment if you want to reload the entire page
    })
    .catch(error => {
      console.error('Error clearing cart:', error);
    });
  }
}