# == Schema Information
#
# Table name: purchases
#
#  id             :bigint           not null, primary key
#  invoice_number :string
#  notes          :text
#  payment_method :string
#  posted_at      :datetime
#  purchase_date  :date
#  status         :string           default("draft")
#  total_amount   :decimal(, )
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  account_id     :bigint           not null
#  supplier_id    :bigint
#
# Indexes
#
#  index_purchases_on_account_id   (account_id)
#  index_purchases_on_posted_at    (posted_at)
#  index_purchases_on_status       (status)
#  index_purchases_on_supplier_id  (supplier_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (supplier_id => suppliers.id)
#
class Purchase < ApplicationRecord
  acts_as_tenant(:account)

  include NumericFormatter

  sanitize_numeric_attributes :total_amount

  enum :status, { draft: 'draft', posted: 'posted', canceled: 'canceled' }, validate: false

  belongs_to :supplier
  has_many :purchase_items, dependent: :destroy
  accepts_nested_attributes_for :purchase_items, allow_destroy: true

  validates :supplier, presence: true
  validates :purchase_date, presence: true

  before_save :calculate_total_amount

  scope :draft, -> { where(status: 'draft') }
  scope :posted, -> { where(status: 'posted') }
  scope :canceled, -> { where(status: 'canceled') }
  scope :ordered, -> { order(purchase_date: :desc) }

  def self.ransackable_attributes(auth_object = nil)
    %w[id purchase_date total_amount status posted_at invoice_number payment_method notes created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[supplier purchase_items]
  end

  def post!
    Purchases::PostPurchase.call(self)
  end

  def cancel!
    update!(status: :canceled)
  end

  def editable?
    draft?
  end

  private

  def calculate_total_amount
    self.total_amount = purchase_items.sum(&:subtotal)
  end
end
