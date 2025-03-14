# == Schema Information
#
# Table name: suppliers
#
#  id           :bigint           not null, primary key
#  address      :string
#  company_name :string
#  contact_name :string
#  document     :string
#  email        :string
#  notes        :text
#  phone        :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_suppliers_on_document  (document) UNIQUE
#
class Supplier < ApplicationRecord
  validates :company_name, :document, presence: true
  validates :document, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

  def self.ransackable_attributes(auth_object = nil)
    ["address", "company_name", "contact_name", "created_at", "document", "email", "id", "id_value", "notes", "phone", "updated_at"]
  end
end
