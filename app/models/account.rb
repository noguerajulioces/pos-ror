# == Schema Information
#
# Table name: accounts
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Account < ApplicationRecord
  has_many :users
  validates :name, presence: true, length: { minimum: 3, maximum: 20 }

end
