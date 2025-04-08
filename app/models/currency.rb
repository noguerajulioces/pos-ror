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
#  account_id    :bigint           not null
#
# Indexes
#
#  index_currencies_on_account_id  (account_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#
class Currency < ApplicationRecord
  acts_as_tenant(:account)

  # Convert amount from guaraníes to this currency
  def convert_from_guarani(amount)
    return 0 if amount.blank? || exchange_rate.blank? || exchange_rate.zero?
    (amount.to_f / exchange_rate).round(2)
  end
end
