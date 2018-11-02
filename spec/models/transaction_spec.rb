# == Schema Information
#
# Table name: transactions
#
#  id              :bigint(8)        not null, primary key
#  credit_id       :bigint(8)
#  debt_id         :bigint(8)
#  user_id         :integer
#  amount_cents    :integer          default(0), not null
#  amount_currency :string(255)      default("USD"), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require 'rails_helper'

RSpec.describe Transaction, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
