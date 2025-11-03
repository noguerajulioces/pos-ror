import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  saveNotes(event) {
    const notes = event.target.value
    
    // Save to session via Rails UJS/Turbo
    fetch('/pos/save_order_notes', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({ notes: notes })
    })
    .then(response => {
      if (!response.ok) {
        console.error('Error saving notes')
      }
    })
    .catch(error => {
      console.error('Error:', error)
    })
  }
}

