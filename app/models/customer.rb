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
#  account_id :bigint           not null
#
# Indexes
#
#  index_customers_on_account_id  (account_id)
#  index_customers_on_email       (email) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#
class Customer < ApplicationRecord
  acts_as_tenant(:account)

  has_many :orders, dependent: :destroy
  # Validaciones para asegurar la integridad de los datos
  validates :first_name, :last_name, presence: true
  validates :document, presence: true, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

  def full_name
    "#{first_name} #{last_name}".strip
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[address city country created_at document email first_name id id_value last_name notes phone state updated_at zip_code]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[]
  end

  def initials
    first_initial = first_name.present? ? first_name[0].upcase : ''
    last_initial = last_name.present? ? last_name[0].upcase : ''

    if first_initial.present? || last_initial.present?
      "#{first_initial}#{last_initial}"
    else
      document.present? ? document[0..1].upcase : 'CG'
    end
  end
end
