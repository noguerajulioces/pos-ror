import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("Cash register controller connected")
  }
  
  open(event) {
    event.preventDefault()
    const form = event.target
    const formData = new FormData(form)
    
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content
    
    fetch(form.action, {
      method: 'POST',
      headers: {
        "X-CSRF-Token": csrfToken,
        "Accept": "application/json"
      },
      body: formData
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        // Reload the page to show the POS interface
        window.location.reload()
      } else {
        // Show error message
        alert(`Error: ${data.errors.join(', ')}`)
      }
    })
    .catch(error => {
      console.error("Error opening cash register:", error)
    })
  }
}