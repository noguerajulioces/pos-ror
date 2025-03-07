import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["sidebar", "backdrop"];

  connect() {
    this.hideSidebar();
  }

  showSidebar() {
    this.sidebarTarget.classList.remove("-translate-x-full");
    this.sidebarTarget.classList.add("translate-x-0");
    this.backdropTarget.classList.remove("hidden");
    this.backdropTarget.classList.add("block");
  }

  hideSidebar() {
    this.sidebarTarget.classList.add("-translate-x-full");
    this.sidebarTarget.classList.remove("translate-x-0");
    this.backdropTarget.classList.add("hidden");
    this.backdropTarget.classList.remove("block");
  }
}
