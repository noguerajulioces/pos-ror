# == Schema Information
#
# Table name: customers
#
#  id         :bigint           not null, primary key
#  address    :string
#  city       :string
#  country    :string
#  document   :string
#  email      :string           not null
#  first_name :string           not null
#  last_name  :string           not null
#  notes      :text
#  phone      :string
#  state      :string
#  zip_code   :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_customers_on_email  (email) UNIQUE
#
class Customer < ApplicationRecord
  # Validaciones para asegurar la integridad de los datos
  validates :first_name, :last_name, presence: true
  validates :document, presence: true, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
end
