import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    id: Number,
    name: String
  }

  showSubcategories() {
    const categoryId = this.idValue;
    const categoryName = this.nameValue;
    
    // Update the selected category name
    document.getElementById('selected-category-name').textContent = categoryName;
    
    // Hide categories, show subcategories container
    document.getElementById('categories-container').classList.add('hidden');
    document.getElementById('subcategories-container').classList.remove('hidden');
    
    // Fetch subcategories
    this.fetchSubcategories(categoryId);
  }
  
  backToCategories() {
    // Hide subcategories, show categories container
    document.getElementById('subcategories-container').classList.add('hidden');
    document.getElementById('categories-container').classList.remove('hidden');
  }
  
  fetchSubcategories(categoryId) {
    const subcategoriesContainer = document.getElementById('subcategories-list');
    
    // Show loading state
    subcategoriesContainer.innerHTML = '<div class="w-full p-4 text-center text-gray-500">Cargando subcategorías...</div>';
    
    // Fetch subcategories from server
    fetch(`/pos/subcategories?category_id=${categoryId}`)
      .then(response => response.json())
      .then(data => {
        if (data.length === 0) {
          subcategoriesContainer.innerHTML = '<div class="w-full p-4 text-center text-gray-500">No hay subcategorías disponibles</div>';
          return;
        }
        
        // Render subcategories
        let html = '';
        data.forEach((subcategory, index) => {
          const borderRight = index % 3 !== 2 ? 'border-r border-dotted border-gray-300' : '';
          const borderBottom = index < data.length - 3 ? 'border-b border-dotted border-gray-300' : '';
          
          html += `
            <div class="w-1/3 p-3 flex flex-col items-center ${borderRight} ${borderBottom}" 
                 data-subcategory-id="${subcategory.id}">
              <div class="w-12 h-12 bg-blue-100 rounded-full flex items-center justify-center mb-2 cursor-pointer">
                <span class="text-blue-600 font-bold">${subcategory.name.charAt(0).toUpperCase()}</span>
              </div>
              <span class="text-sm font-medium cursor-pointer">${subcategory.name}</span>
            </div>
          `;
        });
        
        // Fill remaining cells to maintain grid
        const remainingCells = (3 - (data.length % 3)) % 3;
        for (let i = 0; i < remainingCells; i++) {
          const borderRight = i < remainingCells - 1 ? 'border-r border-dotted border-gray-300' : '';
          
          html += `
            <div class="w-1/3 p-3 flex flex-col items-center ${borderRight}">
              <div class="w-12 h-12 bg-gray-50 rounded-full flex items-center justify-center mb-2 opacity-30">
                <span class="text-gray-400 font-bold">+</span>
              </div>
              <span class="text-sm font-medium text-gray-300">Nueva subcategoría</span>
            </div>
          `;
        }
        
        subcategoriesContainer.innerHTML = html;
      })
      .catch(error => {
        console.error('Error fetching subcategories:', error);
        subcategoriesContainer.innerHTML = '<div class="w-full p-4 text-center text-red-500">Error al cargar subcategorías</div>';
      });
  }
}