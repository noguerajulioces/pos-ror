# == Schema Information
#
# Table name: units
#
#  id           :bigint           not null, primary key
#  abbreviation :string
#  description  :text
#  name         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
require "test_helper"

class UnitTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
