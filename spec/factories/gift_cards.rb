# == Schema Information
#
# Table name: gift_cards
#
#  id               :integer          not null, primary key
#  gift_card_number :string(255)
#  expiration_date  :string(255)
#  person_id        :integer
#  notes            :string(255)
#  created_by       :integer
#  reason           :integer
#  amount_cents     :integer          default(0), not null
#  amount_currency  :string(255)      default("USD"), not null
#  giftable_id      :integer
#  giftable_type    :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  batch_id         :string(255)
#  sequence_number         :string(255)
#  active           :boolean          default(FALSE)
#  secure_code      :string(255)
#  team_id          :integer
#  finance_code     :string(255)
#

FactoryGirl.define do
  factory :gift_card do
    gift_card_number Faker::Number.number(4)
    expiration_date '05/20'
    person_id 1
    notes 'MyString'
    created_by 1
    reason 1
    sequence_number Faker::Number.number(3)
    batch_id Faker::Number.number(10)
  end
end
