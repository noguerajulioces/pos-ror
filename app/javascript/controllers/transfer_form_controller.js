import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"

export default class extends Controller {
  static targets = ["accountSelect", "productWrapper", "productSelect", "productStock"]

  connect() {
    this._initAccountSelect()
  }

  disconnect() {
    this._destroyTomSelect()
  }

  accountChanged() {
    const accountId = this.accountSelectTarget.value

    this.productWrapperTarget.classList.add("hidden")
    this._destroyTomSelect()

    if (!accountId) return

    const url = this.element.dataset.productsUrl.replace("ACCOUNT_ID", accountId)

    fetch(url, { headers: { "Accept": "application/json" } })
      .then(response => response.json())
      .then(products => {
        // Limpiar opciones previas (opción vacía sin texto, el placeholder lo maneja Tom Select)
        this.productSelectTarget.innerHTML = '<option value=""></option>'

        products.forEach(p => {
          const opt = document.createElement("option")
          opt.value = p.id
          opt.dataset.stock = p.stock
          opt.textContent = `${p.name} (SKU: ${p.sku}) — Stock: ${p.stock ?? 0}`
          this.productSelectTarget.appendChild(opt)
        })

        this.productWrapperTarget.classList.remove("hidden")
        this._initProductSelect()
      })
      .catch(() => {
        this.productSelectTarget.innerHTML =
          '<option value="">Error al cargar productos</option>'
        this.productWrapperTarget.classList.remove("hidden")
      })
  }

  _initAccountSelect() {
    if (this.hasAccountSelectTarget && !this.accountSelectTarget.tomselect) {
      // Limpiar texto de la opción vacía para que el placeholder lo maneje Tom Select
      const emptyOpt = this.accountSelectTarget.querySelector('option[value=""]')
      if (emptyOpt) emptyOpt.textContent = ""

      new TomSelect(this.accountSelectTarget, {
        placeholder: "Seleccionar sucursal...",
        allowEmptyOption: false
      })
    }
  }

  _initProductSelect() {
    if (this._tomSelectInstance) {
      this._tomSelectInstance.destroy()
      this._tomSelectInstance = null
    }

    this._tomSelectInstance = new TomSelect(this.productSelectTarget, {
      placeholder: "Buscar producto...",
      allowEmptyOption: false,
      searchField: ["text"],
      render: {
        option: (data, escape) => `<div>${escape(data.text)}</div>`,
        item: (data, escape) => `<div>${escape(data.text)}</div>`
      }
    })
  }

  _destroyTomSelect() {
    if (this._tomSelectInstance) {
      this._tomSelectInstance.destroy()
      this._tomSelectInstance = null
    }
  }
}
