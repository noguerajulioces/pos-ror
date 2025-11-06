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
class Table < ApplicationRecord
  acts_as_tenant(:account)

  has_many :orders, dependent: :nullify

  validates :name, presence: true, uniqueness: { scope: :account_id }
  validates :active, inclusion: { in: [true, false] }

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  def self.ransackable_attributes(auth_object = nil)
    ['name', 'active', 'created_at', 'updated_at']
  end
end
