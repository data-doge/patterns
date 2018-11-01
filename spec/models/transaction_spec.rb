# == Schema Information
#
# Table name: transactions
#
#  id              :bigint(8)        not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  from_id         :integer
#  from_type       :string(255)
#  to_id           :integer
#  to_type         :string(255)
#  notes           :string(255)
#  user_id         :integer
#  amount_cents    :integer          default(0), not null
#  amount_currency :integer          default(0), not null
#

require 'rails_helper'

RSpec.describe Transaction, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
