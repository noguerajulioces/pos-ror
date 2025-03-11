import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    id: Number,
    name: String
  }

  connect() {
    // Store for products data
    this.productsData = [];
    console.log("Subcategory controller connected");
  }

  showProducts() {
    console.log("showProducts called with ID:", this.idValue, "and name:", this.nameValue);
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
    console.log("Fetching products for subcategory ID:", subcategoryId);
    const productsContainer = document.getElementById('products-list');
    
    // Show loading state
    productsContainer.innerHTML = '<div class="w-full p-4 text-center text-gray-500">Cargando productos...</div>';
    
    // Fetch products from server
    fetch(`/pos/products_by_subcategory?subcategory_id=${subcategoryId}`)
      .then(response => {
        console.log("Response status:", response.status);
        return response.json();
      })
      .then(data => {
        console.log("Products data received:", data);
        // Store the products data for later use
        this.productsData = data;
        
        if (data.length === 0) {
          console.log("No products found for this subcategory");
          productsContainer.innerHTML = '<div class="w-full p-4 text-center text-gray-500">No hay productos disponibles</div>';
          return;
        }
        
        // Render products
        let html = '';
        data.forEach((product, index) => {
          console.log(`Processing product ${index}:`, product.name);
          // Format price like Rails number_to_currency with Guaraní currency
          const formattedPrice = new Intl.NumberFormat('es-PY', {
            style: 'decimal',
            minimumFractionDigits: 0,
            maximumFractionDigits: 0,
          }).format(parseInt(product.price));
          
          // Determine stock status and styling
          const stockStatus = parseInt(product.stock) <= 0;
          console.log(`Product ${product.name} stock:`, product.stock, "In stock:", !stockStatus);
          const stockClass = stockStatus ? 'text-red-600 bg-red-100' : 'text-green-600 bg-green-100';
          const stockText = stockStatus ? 'Sin stock' : `Stock: ${product.stock}`;
          
          html += `
            <div class="w-1/3 p-2 product-item" data-product-id="${product.id}">
              <div class="border rounded-lg p-2 hover:border-indigo-500 cursor-pointer h-full flex flex-col ${stockStatus ? 'border-red-300' : ''}">
                <div class="h-24 bg-gray-100 rounded-md mb-2 flex items-center justify-center overflow-hidden">
                  ${product.image_url ? 
                    `<img src="${product.image_url}" alt="${product.image_alt || product.name}" class="w-full h-full object-cover object-center">` : 
                    `<svg class="w-12 h-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                    </svg>`
                  }
                </div>
                <div class="flex-grow">
                  <h3 class="font-medium text-sm">${product.name}</h3>
                  <div class="flex justify-between items-center mt-1">
                    <p class="text-green-600 font-bold">₲s. ${formattedPrice}</p>
                    <span class="${stockClass} inline-flex rounded-full px-2 text-xs font-semibold leading-5">${stockText}</span>
                  </div>
                </div>
              </div>
            </div>
          `;
        });
        
        // After setting the innerHTML, add event listeners to the product items
        console.log("Updating products container with HTML");
        productsContainer.innerHTML = html;
        
        // Add click event listeners to all product items
        const productItems = productsContainer.querySelectorAll('.product-item');
        console.log(`Adding click listeners to ${productItems.length} products`);
        productItems.forEach(item => {
          item.addEventListener('click', (event) => {
            const productId = item.dataset.productId;
            console.log(`Product clicked: ${productId}`);
            this.addToCart(event, productId);
          });
        });
      })
      .catch(error => {
        console.error('Error fetching products:', error);
        productsContainer.innerHTML = '<div class="w-full p-4 text-center text-red-500">Error al cargar productos</div>';
      });
  }
  
  // Update the addToCart method to accept productId as a parameter
  addToCart(event, productId) {
    console.log("addToCart called for product ID:", productId);
    
    // Find the product in our stored data
    const product = this.productsData.find(p => p.id.toString() === productId);
    
    if (!product) {
      console.error('Product not found:', productId);
      return;
    }
    
    console.log("Product found:", product);
    
    // Check if product is in stock
    if (parseInt(product.stock) <= 0) {
      console.log("Product out of stock");
      alert('Este producto está fuera de stock');
      return;
    }
    
    // Add product to cart via Turbo
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content;
    console.log("CSRF token:", csrfToken ? "Found" : "Not found");
    
    console.log("Sending request to add product to cart");
    fetch('/pos/add_product_to_cart', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken,
        'Accept': 'text/vnd.turbo-stream.html'
      },
      body: JSON.stringify({
        product_id: productId,
        quantity: 1
      })
    })
    .then(response => {
      console.log("Response status:", response.status);
      if (!response.ok) {
        throw new Error('Network response was not ok');
      }
      return response.text();
    })
    .then(html => {
      // Let Turbo handle the response
      console.log('Product added to cart successfully');
      console.log('Response HTML length:', html.length);
      
      Turbo.renderStreamMessage(html)
    })
    .catch(error => {
      console.error('Error adding product to cart:', error);
    });
  }
}