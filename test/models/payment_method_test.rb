# == Schema Information
#
# Table name: payment_methods
#
#  id          :bigint           not null, primary key
#  active      :boolean
#  description :text
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
require "test_helper"

class PaymentMethodTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
