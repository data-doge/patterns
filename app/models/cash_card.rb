# frozen_string_literal: true

class CashCard < ApplicationRecord
  has_paper_trail
  monetize :amount_cents
  has_one :reward, as: :rewardable, dependent: :nullify
  belongs_to :user
  belongs_to :person
end
