import { Controller } from "@hotwired/stimulus"

// Handles cascading category → subcategory selects in the product form.
// On connect: if a subcategory is pre-selected (edit mode), restores both dropdowns.
// The hidden category_id field is what actually gets submitted.
export default class extends Controller {
  static targets = ["parentCategory", "subcategoryWrapper", "subcategory", "categoryId"]
  static values = {
    initialParentId: Number,
    initialSubcategoryId: Number
  }

  connect() {
    if (this.initialParentIdValue) {
      this.loadSubcategories(this.initialParentIdValue, this.initialSubcategoryIdValue);
    }
  }

  parentChanged() {
    const parentId = parseInt(this.parentCategoryTarget.value);

    // Reset subcategory
    this.subcategoryTarget.innerHTML = '<option value="">Sin subcategoría</option>';
    this.subcategoryWrapperTarget.classList.add('hidden');

    if (!parentId) {
      this.categoryIdTarget.value = '';
      return;
    }

    // Set category_id to the root category for now (overridden if subcategory chosen)
    this.categoryIdTarget.value = parentId;

    this.loadSubcategories(parentId, null);
  }

  subcategoryChanged() {
    const parentId = parseInt(this.parentCategoryTarget.value);
    const subcategoryId = parseInt(this.subcategoryTarget.value);

    // If subcategory selected → use it; otherwise fall back to root category
    this.categoryIdTarget.value = subcategoryId || parentId;
  }

  loadSubcategories(parentId, preselectId) {
    fetch(`/categories/${parentId}/subcategories`)
      .then(response => response.json())
      .then(subcategories => {
        if (subcategories.length === 0) {
          this.subcategoryWrapperTarget.classList.add('hidden');
          return;
        }

        let options = '<option value="">Sin subcategoría</option>';
        subcategories.forEach(sub => {
          const selected = preselectId && sub.id === preselectId ? 'selected' : '';
          options += `<option value="${sub.id}" ${selected}>${sub.name}</option>`;
        });

        this.subcategoryTarget.innerHTML = options;
        this.subcategoryWrapperTarget.classList.remove('hidden');

        // If a subcategory is pre-selected, make sure category_id reflects it
        if (preselectId) {
          this.categoryIdTarget.value = preselectId;
        }
      })
      .catch(error => console.error('Error loading subcategories:', error));
  }
}
