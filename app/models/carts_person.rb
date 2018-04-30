# frozen_string_literal: true

# == Schema Information
#
# Table name: carts_people
#
#  cart_id   :integer          not null
#  person_id :integer          not null
#  id        :integer          not null, primary key
#

class CartsPerson < ApplicationRecord
  belongs_to :cart, counter_cache: :people_count
  belongs_to :person

  validates :person_id,
    uniqueness: { scope: :cart_id,
                  message: 'Person can only be in a cart once.' }
end
