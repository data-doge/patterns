# frozen_string_literal: true

class ActivationCallUpdateJob
  include Sidekiq::Worker
  sidekiq_options unique: :while_executing
  
  def perform(_useless)
    ActivationCall.ongoing.find_each do |activation_call|
      if activation_call.timeout_error?
        activation_call.failure
        activation_call.save
        activation_call.update_front_end
      end
      sleep 1
    end until ActivationCall.ongoing.empty?
  end
end
