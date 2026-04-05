import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    id: Number,
    name: String
  }

  connect() {
    this.productsData = [];
  }

  showProducts() {
    const subcategoryId = this.idValue;
    const subcategoryName = this.nameValue;

    document.getElementById('selected-product-category').textContent = subcategoryName;
    document.getElementById('subcategories-container').classList.add('hidden');
    document.getElementById('products-container').classList.remove('hidden');

    this.fetchProducts(subcategoryId);
  }

  fetchProducts(subcategoryId) {
    const productsContainer = document.getElementById('products-list');
    productsContainer.innerHTML = '<div class="w-full p-4 text-center text-gray-500">Cargando productos...</div>';

    fetch(`/pos/products_by_subcategory?subcategory_id=${subcategoryId}`)
      .then(response => response.json())
      .then(data => {
        this.productsData = data;

        if (data.length === 0) {
          productsContainer.innerHTML = '<div class="w-full p-4 text-center text-gray-500">No hay productos disponibles</div>';
          return;
        }

        productsContainer.innerHTML = this.renderProductCards(data);

        productsContainer.querySelectorAll('.product-item').forEach(item => {
          item.addEventListener('click', () => this.addToCart(item.dataset.productId));
        });
      })
      .catch(error => {
        console.error('Error fetching products:', error);
        productsContainer.innerHTML = '<div class="w-full p-4 text-center text-red-500">Error al cargar productos</div>';
      });
  }

  addToCart(productId) {
    const product = this.productsData.find(p => p.id.toString() === productId.toString());
    if (!product) return;

    if (parseInt(product.stock) <= 0) {
      alert('Este producto está fuera de stock');
      return;
    }

    const csrfToken = document.querySelector('meta[name="csrf-token"]').content;
    fetch('/pos/add_product_to_cart', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken,
        'Accept': 'text/vnd.turbo-stream.html'
      },
      body: JSON.stringify({ product_id: productId, quantity: 1 })
    })
    .then(response => {
      if (!response.ok) throw new Error('Network response was not ok');
      return response.text();
    })
    .then(html => Turbo.renderStreamMessage(html))
    .catch(error => console.error('Error adding product to cart:', error));
  }

  renderProductCards(products) {
    let html = '';
    products.forEach(product => {
      const formattedPrice = new Intl.NumberFormat('es-PY', {
        style: 'decimal', minimumFractionDigits: 0, maximumFractionDigits: 0
      }).format(parseInt(product.price));

      const outOfStock = parseInt(product.stock) <= 0;
      const stockClass = outOfStock ? 'text-red-600 bg-red-100' : 'text-green-600 bg-green-100';
      const stockText = outOfStock ? 'Sin stock' : `Stock: ${product.stock}`;

      html += `
        <div class="w-1/2 md:w-1/3 p-3 md:p-2 product-item" data-product-id="${product.id}">
          <div class="border rounded-lg p-3 md:p-2 hover:border-indigo-500 cursor-pointer h-full flex flex-col ${outOfStock ? 'border-red-300' : ''}">
            <div class="h-32 md:h-24 bg-gray-100 rounded-md mb-3 md:mb-2 flex items-center justify-center overflow-hidden">
              ${product.image_url
                ? `<img src="${product.image_url}" alt="${product.image_alt || product.name}" class="w-full h-full object-cover object-center">`
                : `<svg class="w-16 h-16 md:w-12 md:h-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                  </svg>`
              }
            </div>
            <div class="flex-grow">
              <h3 class="font-medium text-sm">${product.name}</h3>
              <div class="flex justify-between items-center mt-2 md:mt-1">
                <p class="text-green-600 font-bold text-sm">₲s. ${formattedPrice}</p>
                <span class="${stockClass} inline-flex rounded-full px-2 text-xs font-semibold leading-5">${stockText}</span>
              </div>
            </div>
          </div>
        </div>
      `;
    });
    return html;
  }
}
