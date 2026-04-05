import { Controller } from "@hotwired/stimulus"

// Carga dinámicamente los productos de la sucursal destino seleccionada
export default class extends Controller {
  static targets = ["accountSelect", "productWrapper", "productSelect", "productStock"]

  accountChanged() {
    const accountId = this.accountSelectTarget.value

    // Ocultar y limpiar el selector de producto
    this.productWrapperTarget.classList.add("hidden")
    this.productSelectTarget.innerHTML = '<option value="">Cargando...</option>'

    if (!accountId) return

    const url = this.element.dataset.productsUrl.replace("ACCOUNT_ID", accountId)

    fetch(url, { headers: { "Accept": "application/json" } })
      .then(response => response.json())
      .then(products => {
        if (products.length === 0) {
          this.productSelectTarget.innerHTML =
            '<option value="">Sin productos simples en esta sucursal</option>'
          this.productWrapperTarget.classList.remove("hidden")
          return
        }

        let options = '<option value="">Seleccionar producto destino...</option>'
        products.forEach(p => {
          options += `<option value="${p.id}" data-stock="${p.stock}">
            ${p.name} (SKU: ${p.sku}) — Stock actual: ${p.stock}
          </option>`
        })

        this.productSelectTarget.innerHTML = options
        this.productWrapperTarget.classList.remove("hidden")
      })
      .catch(() => {
        this.productSelectTarget.innerHTML =
          '<option value="">Error al cargar productos</option>'
        this.productWrapperTarget.classList.remove("hidden")
      })
  }
}
