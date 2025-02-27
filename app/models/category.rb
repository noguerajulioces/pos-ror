# == Schema Information
#
# Table name: categories
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  parent_id  :integer
#
class Category < ApplicationRecord
  has_many :products
  belongs_to :parent, class_name: "Category", optional: true
  has_many :subcategories, class_name: "Category", foreign_key: "parent_id"

  validates :name, presence: true
end
