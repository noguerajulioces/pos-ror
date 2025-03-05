import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    id: Number,
    name: String
  }

  showProducts() {
    const subcategoryId = this.idValue;
    const subcategoryName = this.nameValue;
    
    // Update the selected subcategory name
    document.getElementById('selected-product-category').textContent = subcategoryName;
    
    // Hide subcategories, show products container
    document.getElementById('subcategories-container').classList.add('hidden');
    document.getElementById('products-container').classList.remove('hidden');
    
    // Fetch products
    this.fetchProducts(subcategoryId);
  }
  
  fetchProducts(subcategoryId) {
    const productsContainer = document.getElementById('products-list');
    
    // Show loading state
    productsContainer.innerHTML = '<div class="w-full p-4 text-center text-gray-500">Cargando productos...</div>';
    
    // Fetch products from server
    fetch(`/pos/products_by_subcategory?subcategory_id=${subcategoryId}`)
      .then(response => response.json())
      .then(data => {
        if (data.length === 0) {
          productsContainer.innerHTML = '<div class="w-full p-4 text-center text-gray-500">No hay productos disponibles</div>';
          return;
        }
        
        // Render products
        let html = '';
        data.forEach((product, index) => {
          // Use the direct image_url property from the product
          html += `
            <div class="w-1/3 p-2" data-product-id="${product.id}">
              <div class="border rounded-lg p-2 hover:border-indigo-500 cursor-pointer h-full flex flex-col">
                <div class="h-24 bg-gray-100 rounded-md mb-2 flex items-center justify-center overflow-hidden">
                  ${product.image_url ? 
                    `<img src="${product.image_url}" alt="${product.image_alt || product.name}" class="h-full w-full object-cover">` : 
                    `<svg class="w-12 h-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                    </svg>`
                  }
                </div>
                <div class="flex-grow">
                  <h3 class="font-medium text-sm">${product.name}</h3>
                  <p class="text-green-600 font-bold mt-1">$${parseFloat(product.price).toFixed(2)}</p>
                </div>
              </div>
            </div>
          `;
        });
        
        productsContainer.innerHTML = html;
      })
      .catch(error => {
        console.error('Error fetching products:', error);
        productsContainer.innerHTML = '<div class="w-full p-4 text-center text-red-500">Error al cargar productos</div>';
      });
  }
}