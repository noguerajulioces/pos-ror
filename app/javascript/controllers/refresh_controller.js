import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  reload() {
    // Simple page refresh
    window.location.reload()
    
    // Alternatively, you could use Turbo to visit the current page
    // import { visit } from "@hotwired/turbo"
    // visit(window.location.href)
  }
}