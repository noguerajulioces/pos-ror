// app/javascript/controllers/image_preview_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input", "preview", "svg"]

  previewImage() {
    const file = this.inputTarget.files[0];
    if (file) {
      const reader = new FileReader();
      reader.onload = (event) => {
        // Inyectamos el preview con un tamaño mayor (por ejemplo, 300x300)
        this.previewTarget.innerHTML = `
          <img 
            src="${event.target.result}" 
            alt="Vista previa" 
            class="w-[300px] h-[300px] object-cover rounded-md mx-auto"
          >
        `;
        // Ocultar el svg decorativo
        if (this.hasSvgTarget) {
          this.svgTarget.style.display = "none";
        }
      };
      reader.readAsDataURL(file);
    } else {
      this.previewTarget.innerHTML = "";
      // Si no hay archivo, mostramos el svg nuevamente
      if (this.hasSvgTarget) {
        this.svgTarget.style.display = "";
      }
    }
  }
}
