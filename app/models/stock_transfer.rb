# == Schema Information
#
# Table name: stock_transfers
#
#  id                :bigint           not null, primary key
#  from_item_type    :string           not null
#  quantity          :decimal(10, 3)   not null
#  reason            :string
#  status            :string           default("pending"), not null
#  to_item_type      :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  from_account_id   :bigint           not null
#  from_item_id      :bigint           not null
#  to_account_id     :bigint           not null
#  to_item_id        :bigint           not null
#  transferred_by_id :bigint           not null
#
# Indexes
#
#  index_stock_transfers_on_from_account_id                  (from_account_id)
#  index_stock_transfers_on_from_item_type_and_from_item_id  (from_item_type,from_item_id)
#  index_stock_transfers_on_status                           (status)
#  index_stock_transfers_on_to_account_id                    (to_account_id)
#  index_stock_transfers_on_to_item_type_and_to_item_id      (to_item_type,to_item_id)
#  index_stock_transfers_on_transferred_by_id                (transferred_by_id)
#
# Foreign Keys
#
#  fk_rails_...  (from_account_id => accounts.id)
#  fk_rails_...  (to_account_id => accounts.id)
#  fk_rails_...  (transferred_by_id => users.id)
#
class StockTransfer < ApplicationRecord
  # Sin acts_as_tenant — esta tabla es cross-tenant por diseño

  enum :status, {
    pending: 'pending',
    completed: 'completed',
    cancelled: 'cancelled'
  }

  belongs_to :from_account, class_name: 'Account'
  belongs_to :to_account, class_name: 'Account'
  belongs_to :from_item, polymorphic: true
  belongs_to :to_item, polymorphic: true
  belongs_to :transferred_by, class_name: 'User'

  validates :quantity, numericality: { greater_than: 0 }
  validates :reason, presence: true
  validates :from_account, :to_account, presence: true
  validate :accounts_must_differ

  private

  def accounts_must_differ
    if from_account_id == to_account_id
      errors.add(:to_account, 'debe ser una sucursal diferente a la de origen')
    end
  end
end
