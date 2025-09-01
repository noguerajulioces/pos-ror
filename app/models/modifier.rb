# == Schema Information
#
# Table name: modifiers
#
#  id                :bigint           not null, primary key
#  deleted_at        :datetime
#  name              :string           not null
#  price_delta       :decimal(12, 2)   default(0.0)
#  sku               :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  account_id        :bigint           not null
#  modifier_group_id :bigint           not null
#
# Indexes
#
#  index_modifiers_on_account_id         (account_id)
#  index_modifiers_on_deleted_at         (deleted_at)
#  index_modifiers_on_modifier_group_id  (modifier_group_id)
#  index_modifiers_on_sku                (sku)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (modifier_group_id => modifier_groups.id)
#
class Modifier < ApplicationRecord
  acts_as_tenant(:account)
  acts_as_paranoid

  # Validaciones
  validates :name, presence: true
  validates :name, uniqueness: { scope: :modifier_group_id }
  validates :price_delta, numericality: true
  validates :sku, uniqueness: { scope: :account_id }, allow_blank: true

  # Asociaciones
  belongs_to :modifier_group

  # Scopes
  scope :ordered, -> { order(:name) }
  scope :with_price, -> { where.not(price_delta: 0) }
  scope :free, -> { where(price_delta: 0) }

  # Métodos
  def display_name
    if price_delta.zero?
      name
    elsif price_delta.positive?
      "#{name} (+#{number_to_currency(price_delta)})"
    else
      "#{name} (#{number_to_currency(price_delta)})"
    end
  end

  def free?
    price_delta.zero?
  end

  def paid?
    price_delta.positive?
  end

  def discount?
    price_delta.negative?
  end

  private

  def number_to_currency(amount)
    ActionController::Base.helpers.number_to_currency(amount, unit: '₲s. ', precision: 0)
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[name price_delta sku created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[modifier_group]
  end
end
