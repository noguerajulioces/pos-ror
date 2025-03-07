import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dropdown"
export default class extends Controller {
  static targets = ["menu"];

  connect() {
  }

  toggle(event) {
    event.preventDefault();

    this.menuTarget.classList.toggle("hidden");
  }
}
