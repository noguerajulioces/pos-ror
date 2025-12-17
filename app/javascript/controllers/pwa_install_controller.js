import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="pwa-install"
export default class extends Controller {
  static targets = ["button", "unsupportedMessage"];

  connect() {
    console.log("PWA Install controller connected");

    // Capture the beforeinstallprompt event
    window.addEventListener("beforeinstallprompt", (e) => {
      console.log("beforeinstallprompt event fired");
      // Prevent the mini-infobar from appearing on mobile
      e.preventDefault();
      // Store the event for later use
      this.deferredPrompt = e;
      // Show the install button
      this.showButton();
    });

    // Hide button if app is already installed
    window.addEventListener("appinstalled", () => {
      console.log("PWA was installed");
      this.hideButton();
      this.deferredPrompt = null;
    });

    // Check if browser doesn't support beforeinstallprompt after a delay
    setTimeout(() => {
      if (!this.deferredPrompt && this.hasUnsupportedMessageTarget) {
        console.log("Browser does not support PWA installation");
        this.showUnsupportedMessage();
      }
    }, 2000);
  }

  async installApp() {
    console.log("Install button clicked");

    if (!this.deferredPrompt) {
      console.log("No deferred prompt available");
      return;
    }

    // Show the install prompt
    this.deferredPrompt.prompt();

    // Wait for the user's response
    const { outcome } = await this.deferredPrompt.userChoice;
    console.log(`User response to install prompt: ${outcome}`);

    // Clear the deferred prompt
    this.deferredPrompt = null;

    // Hide the button after installation
    if (outcome === "accepted") {
      this.hideButton();
    }
  }

  showButton() {
    if (this.hasButtonTarget) {
      this.buttonTarget.classList.remove("hidden");
      console.log("Install button shown");
    }
  }

  hideButton() {
    if (this.hasButtonTarget) {
      this.buttonTarget.classList.add("hidden");
      console.log("Install button hidden");
    }
  }

  showUnsupportedMessage() {
    if (this.hasUnsupportedMessageTarget) {
      this.unsupportedMessageTarget.classList.remove("hidden");
      console.log("Unsupported message shown");
    }
  }
}
