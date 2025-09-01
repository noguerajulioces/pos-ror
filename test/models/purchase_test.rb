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
require 'test_helper'

class PurchaseTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
