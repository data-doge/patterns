# frozen_string_literal: true
class CartsUser < ApplicationRecord
  belongs_to :cart
  belongs_to :user

  validates :user_id,
    uniqueness: { scope:   :cart_id,
                  message: 'can only have a cart one time.' }
  # validates :current_cart,
  #   uniqueness: { scope: :user_id, message: 'only one current cart possible' }
end
