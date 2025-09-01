# == Schema Information
#
# Table name: tax_rates
#
#  id         :bigint           not null, primary key
#  deleted_at :datetime
#  is_active  :boolean          default(TRUE)
#  name       :string           not null
#  percentage :decimal(5, 2)    not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  account_id :bigint           not null
#
# Indexes
#
#  index_tax_rates_on_account_id  (account_id)
#  index_tax_rates_on_deleted_at  (deleted_at)
#  index_tax_rates_on_is_active   (is_active)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#
class TaxRate < ApplicationRecord
  acts_as_tenant(:account)
  acts_as_paranoid

  # Validaciones
  validates :name, presence: true
  validates :percentage, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :name, uniqueness: { scope: :account_id }

  # Asociaciones
  has_many :products, dependent: :nullify

  # Scopes
  scope :active, -> { where(is_active: true) }
  scope :ordered, -> { order(:name) }

  # Métodos
  def display_name
    "#{name} (#{percentage}%)"
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[name percentage is_active created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[products]
  end
end
