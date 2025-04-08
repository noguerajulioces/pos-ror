# == Schema Information
#
# Table name: categories
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  account_id :bigint           not null
#  parent_id  :integer
#
# Indexes
#
#  index_categories_on_account_id  (account_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#
class Category < ApplicationRecord
  acts_as_tenant(:account)

  has_many :products
  belongs_to :parent, class_name: 'Category', optional: true
  has_many :subcategories, class_name: 'Category', foreign_key: 'parent_id'

  validates :name, presence: true
  before_destroy :ensure_no_products

  private

  def ensure_no_products
    if products.exists?
      errors.add(:base, 'No puedes eliminar una categoría con productos asociados')
      throw(:abort) # Evita que se elimine la categoría
    end
  end
end
