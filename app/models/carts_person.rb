# frozen_string_literal: true

# == Schema Information
#
# Table name: carts_people
#
#  cart_id   :bigint(8)        not null
#  person_id :bigint(8)        not null
#  id        :bigint(8)        not null, primary key
#

class CartsPerson < ApplicationRecord
  belongs_to :cart, counter_cache: :people_count
  belongs_to :person

  validates :person_id,
    uniqueness: { scope: :cart_id,
                  message: 'Person can only be in a cart once.' }

  after_commit :update_rapidpro if ENV['RAPIDPRO_TOKEN']

  def update_rapidpro
    RapidproGroupJob.perform_async(cart.id)
  end
end
