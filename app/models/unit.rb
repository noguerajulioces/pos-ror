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
class Unit < ApplicationRecord
  acts_as_tenant(:account)

  acts_as_paranoid

  has_many :products

  # Validaciones, por ejemplo:
  validates :name, presence: true, uniqueness: { scope: :deleted_at }
end
