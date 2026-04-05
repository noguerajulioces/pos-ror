import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    id: Number,
    name: String
  }

  connect() {
    this.directProductsData = [];
  }

  showSubcategories() {
    const categoryId = this.idValue;
    const categoryName = this.nameValue;

    document.getElementById('selected-category-name').textContent = categoryName;

    document.getElementById('categories-container').classList.add('hidden');
    document.getElementById('subcategories-container').classList.remove('hidden');
    document.getElementById('products-container').classList.add('hidden');

    document.getElementById('category-direct-products').classList.add('hidden');
    document.getElementById('category-direct-products-list').innerHTML = '';

    this.fetchSubcategories(categoryId);
    this.fetchDirectProducts(categoryId);
  }

  backToCategories() {
    document.getElementById('subcategories-container').classList.add('hidden');
    document.getElementById('products-container').classList.add('hidden');
    document.getElementById('categories-container').classList.remove('hidden');
  }

  backToSubcategories() {
    document.getElementById('products-container').classList.add('hidden');
    document.getElementById('subcategories-container').classList.remove('hidden');
  }

  fetchSubcategories(categoryId) {
    const subcategoriesContainer = document.getElementById('subcategories-list');
    subcategoriesContainer.innerHTML = '<div class="w-full p-4 text-center text-gray-500">Cargando...</div>';

    fetch(`/pos/subcategories?category_id=${categoryId}`)
      .then(response => response.json())
      .then(data => {
        if (data.length === 0) {
          subcategoriesContainer.innerHTML = '';
          return;
        }

        let html = '';
        data.forEach((subcategory, index) => {
          const mobileBorderR = (index % 2 !== 1) ? 'border-r border-dotted border-gray-300' : '';
          const desktopBorderR = (index % 3 !== 2) ? 'md:border-r md:border-dotted md:border-gray-300' : '';
          const mobileRow = Math.floor(index / 2);
          const desktopRow = Math.floor(index / 3);
          const totalMobileRows = Math.ceil(data.length / 2);
          const totalDesktopRows = Math.ceil(data.length / 3);
          const mobileBorderB = (mobileRow < totalMobileRows - 1) ? 'border-b border-dotted border-gray-300' : '';
          const desktopBorderB = (desktopRow < totalDesktopRows - 1) ? 'md:border-b md:border-dotted md:border-gray-300' : '';

          html += `
            <div class="w-1/2 md:w-1/3 p-4 md:p-3 flex flex-col items-center ${mobileBorderR} ${desktopBorderR} ${mobileBorderB} ${desktopBorderB}"
                 data-controller="subcategory"
                 data-action="click->subcategory#showProducts"
                 data-subcategory-id-value="${subcategory.id}"
                 data-subcategory-name-value="${subcategory.name}">
              <div class="w-16 h-16 md:w-12 md:h-12 bg-blue-100 rounded-full flex items-center justify-center mb-2 cursor-pointer">
                <span class="text-blue-600 font-bold text-lg md:text-base">${subcategory.name.charAt(0).toUpperCase()}</span>
              </div>
              <span class="text-sm font-medium cursor-pointer text-center">${subcategory.name}</span>
            </div>
          `;
        });

        const remainingCellsDesktop = (3 - (data.length % 3)) % 3;
        for (let i = 0; i < remainingCellsDesktop; i++) {
          const desktopBorderR = (i % 3 !== 2) ? 'md:border-r md:border-dotted md:border-gray-300' : '';
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

  fetchDirectProducts(categoryId) {
    fetch(`/pos/products_by_category?category_id=${categoryId}`)
      .then(response => response.json())
      .then(data => {
        if (data.length === 0) return;

        this.directProductsData = data;
        const section = document.getElementById('category-direct-products');
        const list = document.getElementById('category-direct-products-list');

        list.innerHTML = this.renderProductCards(data);
        section.classList.remove('hidden');

        list.querySelectorAll('.product-item').forEach(item => {
          item.addEventListener('click', () => this.addToCart(item.dataset.productId));
        });
      })
      .catch(error => console.error('Error fetching direct products:', error));
  }

  addToCart(productId) {
    const product = this.directProductsData.find(p => p.id.toString() === productId.toString());
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
