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
    document.getElementById('products-container').classList.add('hidden');
    
    // Fetch subcategories
    this.fetchSubcategories(categoryId);
  }
  
  backToCategories() {
    // Hide subcategories and products, show categories container
    document.getElementById('subcategories-container').classList.add('hidden');
    document.getElementById('products-container').classList.add('hidden');
    document.getElementById('categories-container').classList.remove('hidden');
  }
  
  backToSubcategories() {
    // Hide products, show subcategories
    document.getElementById('products-container').classList.add('hidden');
    document.getElementById('subcategories-container').classList.remove('hidden');
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
        // Mobile: 2 columns, Desktop: 3 columns
        let html = '';
        data.forEach((subcategory, index) => {
          // Mobile: 2 columns - border right except last column of row (odd index)
          // Desktop: 3 columns - border right except last column of row (index % 3 == 2)
          const mobileBorderR = (index % 2 !== 1) ? 'border-r border-dotted border-gray-300' : '';
          const desktopBorderR = (index % 3 !== 2) ? 'md:border-r md:border-dotted md:border-gray-300' : '';
          
          // Calculate rows for mobile (2 cols) and desktop (3 cols)
          const mobileRow = Math.floor(index / 2);
          const desktopRow = Math.floor(index / 3);
          const totalMobileRows = Math.ceil(data.length / 2);
          const totalDesktopRows = Math.ceil(data.length / 3);
          
          // Border bottom: show except in last row
          const mobileBorderB = (mobileRow < totalMobileRows - 1) ? 'border-b border-dotted border-gray-300' : '';
          const desktopBorderB = (desktopRow < totalDesktopRows - 1) ? 'md:border-b md:border-dotted md:border-gray-300' : '';
          
          html += `
            <div class="w-1/2 md:w-1/3 p-4 md:p-3 flex flex-col items-center ${mobileBorderR} ${desktopBorderR} ${mobileBorderB} ${desktopBorderB}" 
                 data-controller="subcategory"
                 data-action="click->subcategory#showProducts"
                 data-subcategory-id-value="${subcategory.id}"
                 data-subcategory-name-value="${subcategory.name}">
              <div class="w-16 h-16 md:w-12 md:h-12 bg-blue-100 rounded-full flex items-center justify-center mb-2 md:mb-2 cursor-pointer">
                <span class="text-blue-600 font-bold text-lg md:text-base">${subcategory.name.charAt(0).toUpperCase()}</span>
              </div>
              <span class="text-sm md:text-sm font-medium cursor-pointer text-center">${subcategory.name}</span>
            </div>
          `;
        });
        
        // Fill remaining cells to maintain grid - only for desktop (3 columns)
        // In mobile (2 columns) we don't need to fill if there's an even number of items
        const remainingCellsDesktop = (3 - (data.length % 3)) % 3;
        
        for (let i = 0; i < remainingCellsDesktop; i++) {
          // Desktop: border right except last column
          const desktopBorderR = (i % 3 !== 2 && i < remainingCellsDesktop) ? 'md:border-r md:border-dotted md:border-gray-300' : '';
          
          html += `
            <div class="hidden md:flex w-1/3 p-3 flex-col items-center ${desktopBorderR}">
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