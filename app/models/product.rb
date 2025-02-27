class Product < ApplicationRecord
  belongs_to :category
  has_many :sale_items
  has_many :inventory_movements
end
