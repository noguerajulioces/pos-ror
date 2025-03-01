// app/javascript/controllers/image_preview_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input", "preview"]

  previewImage() {
    const file = this.inputTarget.files[0];
    if (file) {
      const reader = new FileReader();
      reader.onload = (event) => {
        this.previewTarget.innerHTML = `
          <img
            src="${event.target.result}"
            alt="Vista previa"
            class="w-[100px] h-[100px] object-cover rounded-md"
          >
        `;
      };
      reader.readAsDataURL(file);
    } else {
      this.previewTarget.innerHTML = "";
    }
  }
}
