class Category < ApplicationRecord
  has_many :products
  belongs_to :parent, class_name: "Category", optional: true
  has_many :subcategories, class_name: "Category", foreign_key: "parent_id"
end
