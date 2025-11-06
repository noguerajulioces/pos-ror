# == Schema Information
#
# Table name: tables
#
#  id         :bigint           not null, primary key
#  active     :boolean          default(TRUE), not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  account_id :bigint           not null
#
# Indexes
#
#  index_tables_on_account_id  (account_id)
#  index_tables_on_active      (active)
#  index_tables_on_name        (name)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#
require "test_helper"

class TableTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
