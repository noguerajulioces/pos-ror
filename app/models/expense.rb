# == Schema Information
#
# Table name: expenses
#
#  id                :bigint           not null, primary key
#  amount            :decimal(, )
#  category          :string
#  description       :text
#  expense_date      :date
#  reference_number  :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  payment_method_id :bigint
#  purchase_id       :bigint
#
# Indexes
#
#  index_expenses_on_category           (category)
#  index_expenses_on_payment_method_id  (payment_method_id)
#  index_expenses_on_purchase_id        (purchase_id)
#  index_expenses_on_reference_number   (reference_number)
#
# Foreign Keys
#
#  fk_rails_...  (payment_method_id => payment_methods.id)
#  fk_rails_...  (purchase_id => purchases.id)
#
class Expense < ApplicationRecord
  include NumericFormatter
  belongs_to :purchase, optional: true # Si algunos gastos no están asociados a una compra
  belongs_to :payment_method, optional: true # Si algunos gastos no están asociados a un método de pago

  # Define enum for category
  enum :category, {
    supplies: "supplies",
    utilities: "utilities",
    rent: "rent",
    salaries: "salaries",
    maintenance: "maintenance",
    marketing: "marketing",
    transportation: "transportation",
    taxes: "taxes",
    other: "other"
  }

  sanitize_numeric_attributes :amount

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :expense_date, presence: true

  def self.ransackable_attributes(auth_object = nil)
    [ "amount", "category", "description", "expense_date", "payment_method_id", "reference_number" ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "payment_method" ]
  end
end
