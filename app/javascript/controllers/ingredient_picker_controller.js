import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("Ingredient picker controller connected!")
    this.selectedIngredients = new Map()
  }

  search(event) {
    const query = event.target.value.toLowerCase()
    const cards = document.querySelectorAll('.ingredient-card')
    
    cards.forEach(card => {
      const name = card.dataset.ingredientName?.toLowerCase() || ''
      const sku = card.querySelector('p')?.textContent?.toLowerCase() || ''
      
      if (name.includes(query) || sku.includes(query)) {
        card.style.display = 'block'
      } else {
        card.style.display = 'none'
      }
    })
  }

  selectIngredient(event) {
    const card = event.currentTarget
    const ingredientId = card.dataset.ingredientId
    const ingredientName = card.dataset.ingredientName
    
    console.log("Selecting ingredient:", ingredientName)
    
    // Simple toggle for now
    if (card.classList.contains('border-indigo-500')) {
      card.classList.remove('border-indigo-500', 'bg-indigo-50')
      this.selectedIngredients.delete(ingredientId)
    } else {
      card.classList.add('border-indigo-500', 'bg-indigo-50')
      this.selectedIngredients.set(ingredientId, {
        id: ingredientId,
        name: ingredientName
      })
    }
    
    this.updateSelectedSection()
  }

  updateSelectedSection() {
    const selectedSection = document.getElementById('selected-ingredients')
    const container = document.getElementById('selected-ingredients-container')
    
    if (!selectedSection || !container) return
    
    if (this.selectedIngredients.size === 0) {
      selectedSection.classList.add('hidden')
      return
    }
    
    selectedSection.classList.remove('hidden')
    container.innerHTML = ''
    
    this.selectedIngredients.forEach((ingredient, id) => {
      const div = document.createElement('div')
      div.className = 'p-4 bg-gray-50 rounded-lg'
      div.innerHTML = `
        <div class="flex items-center justify-between">
          <span class="font-medium">${ingredient.name}</span>
          <input type="hidden" name="recipe_components[${id}][ingredient_id]" value="${id}">
          <input type="number" name="recipe_components[${id}][quantity]" value="1" min="0.001" step="0.001" class="w-20 px-2 py-1 border rounded">
        </div>
      `
      container.appendChild(div)
    })
  }
}