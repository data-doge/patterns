# frozen_string_literal: true
class CartsUser < ApplicationRecord
  belongs_to :cart
  belongs_to :user

  validates :user_id,
    uniqueness: { scope:   :cart_id,
                  message: 'can only have a cart one time.' }

end
