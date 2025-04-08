# == Schema Information
#
# Table name: units
#
#  id           :bigint           not null, primary key
#  abbreviation :string
#  deleted_at   :datetime
#  description  :text
#  name         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  account_id   :bigint           not null
#
# Indexes
#
#  index_units_on_account_id  (account_id)
#  index_units_on_deleted_at  (deleted_at)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#
require 'test_helper'

class UnitTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
