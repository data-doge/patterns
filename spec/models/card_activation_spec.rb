# == Schema Information
#
# Table name: card_activations
#
#  id               :integer          not null, primary key
#  full_card_number :string(255)
#  expiration_date  :string(255)
#  sequence_number  :string(255)
#  secure_code      :string(255)
#  batch_id         :string(255)
#  status           :string(255)      default("created")
#  user_id          :integer
#  gift_card_id     :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  amount_cents     :integer          default(0), not null
#  amount_currency  :string(255)      default("USD"), not null
#

require 'rails_helper'

RSpec.describe CardActivation, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
