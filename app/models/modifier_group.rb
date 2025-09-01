# == Schema Information
#
# Table name: modifier_groups
#
#  id         :bigint           not null, primary key
#  deleted_at :datetime
#  max_select :integer          default(1)
#  min_select :integer          default(0)
#  name       :string           not null
#  required   :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  account_id :bigint           not null
#
# Indexes
#
#  index_modifier_groups_on_account_id  (account_id)
#  index_modifier_groups_on_deleted_at  (deleted_at)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#
class ModifierGroup < ApplicationRecord
  acts_as_tenant(:account)
  acts_as_paranoid

  # Validaciones
  validates :name, presence: true
  validates :name, uniqueness: { scope: :account_id }
  validates :min_select, numericality: { greater_than_or_equal_to: 0 }
  validates :max_select, numericality: { greater_than_or_equal_to: :min_select }
  validate :max_select_greater_than_min_select

  # Asociaciones
  has_many :modifiers, dependent: :destroy
  has_many :modifier_groups_products, dependent: :destroy
  has_many :products, through: :modifier_groups_products

  # Scopes
  scope :ordered, -> { order(:name) }
  scope :required, -> { where(required: true) }

  # Métodos
  def display_name
    required_text = required? ? ' (Requerido)' : ''
    "#{name}#{required_text}"
  end

  def selection_range_text
    if min_select == max_select
      "Seleccionar #{min_select}"
    elsif min_select == 0
      "Hasta #{max_select}"
    else
      "#{min_select} a #{max_select}"
    end
  end

  private

  def max_select_greater_than_min_select
    return unless max_select && min_select

    if max_select < min_select
      errors.add(:max_select, 'debe ser mayor o igual que la selección mínima')
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[name min_select max_select required created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[modifiers modifier_groups_products products]
  end
end
