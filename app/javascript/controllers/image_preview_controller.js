// app/javascript/controllers/image_preview_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input", "preview", "svg"]

  connect() {
    const initialUrl = this.previewTarget.dataset.imagePreviewInitialUrl;
    if (initialUrl && initialUrl.length > 0) {
      this.previewTarget.innerHTML = `
        <img 
          src="${initialUrl}" 
          alt="Vista previa" 
          class="w-[300px] h-[300px] object-cover rounded-md mx-auto"
        >
      `;
    }
  }

  previewImage() {
    const file = this.inputTarget.files[0];
    if (file) {
      const reader = new FileReader();
      reader.onload = (event) => {
        this.previewTarget.innerHTML = `
          <img 
            src="${event.target.result}" 
            alt="Vista previa" 
            class="w-[300px] h-[300px] object-cover rounded-md mx-auto"
          >
        `;
      };
      reader.readAsDataURL(file);
    } else {
      this.previewTarget.innerHTML = "";
    }
  }
}
