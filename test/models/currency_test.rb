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
#
require 'test_helper'

class CurrencyTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
