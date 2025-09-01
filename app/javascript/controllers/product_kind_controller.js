import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["kind", "recipeSection", "comboSection", "modifierSection", "simpleSection"]

  connect() {
    this.toggleSections()
  }

  toggleSections() {
    const selectedKind = this.kindTarget.value
    
    // Ocultar todas las secciones primero
    this.hideAllSections()
    
    // Mostrar sección según el tipo seleccionado
    switch (selectedKind) {
      case 'recipe':
        this.showSection(this.recipeSectionTarget)
        break
      case 'combo':
        this.showSection(this.comboSectionTarget)
        break
      case 'modifier':
        this.showSection(this.modifierSectionTarget)
        break
      case 'simple':
      default:
        this.showSection(this.simpleSectionTarget)
        break
    }
  }

  hideAllSections() {
    this.recipeSectionTarget?.classList.add('hidden')
    this.comboSectionTarget?.classList.add('hidden')
    this.modifierSectionTarget?.classList.add('hidden')
    this.simpleSectionTarget?.classList.add('hidden')
  }

  showSection(section) {
    if (section) {
      section.classList.remove('hidden')
    }
  }
}
