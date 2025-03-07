# == Schema Information
#
# Table name: cash_registers
#
#  id             :bigint           not null, primary key
#  close_at       :datetime
#  final_amount   :decimal(, )
#  initial_amount :decimal(, )
#  open_at        :datetime
#  status         :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  user_id        :bigint           not null
#
# Indexes
#
#  index_cash_registers_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require "test_helper"

class CashRegisterTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
