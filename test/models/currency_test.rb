# == Schema Information
#
# Table name: currencies
#
#  id            :bigint           not null, primary key
#  code          :string
#  display       :boolean
#  exchange_rate :decimal(, )
#  flag_url      :string
#  name          :string
#  symbol        :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  account_id    :bigint           not null
#
# Indexes
#
#  index_currencies_on_account_id  (account_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#
require 'test_helper'

class CurrencyTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
