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
class Unit < ApplicationRecord
  has_many :products

  # Validaciones, por ejemplo:
  validates :name, presence: true, uniqueness: true
end
