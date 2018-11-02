# frozen_string_literal: true

require 'active_support/concern'

module Rewardable
  # a rewardable object can be assigned and unassigned.
  # has an amount_cents and amount_denomination
  # has a created_by
  # has a user_id

  extend ActiveSupport::Concern
  
  # may not be necessary because of dependent :nullify
  def unassign 
    self.reward_id = nil
    self.save
  end

  def assign(reward_id)
    return false if reward_id.nil?

    if self.reward_id.present?
      errors.add(:base, "This #{self.class.downcase} has already been assigned")
      raise ActiveRecord::RecordInvalid.new(self)
    else
      self.reward_id = reward_id
      self.save
    end
  end
end
