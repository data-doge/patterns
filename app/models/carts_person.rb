# frozen_string_literal: true
class CartsPerson < ApplicationRecord
  belongs_to :cart
  belongs_to :person

  validates :person_id,
    uniqueness: { scope: :cart_id,
                  message: 'Person can only be in a cart once.' }
end
