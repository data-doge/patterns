# == Schema Information
#
# Table name: cash_cards
#
#  id                :bigint(8)        not null, primary key
#  amount_cents      :integer          default(0), not null
#  amount_currency   :string(255)      default("USD"), not null
#  notes             :string(255)
#  reward_id         :integer
#  person_id         :integer
#  created_by        :integer          not null
#  user_id           :integer
#  legacy_attributes :text(65535)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

require 'rails_helper'

RSpec.describe CashCard, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
