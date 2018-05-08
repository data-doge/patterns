# frozen_string_literal: true

class ActivationCallUpdateJob
  include Sidekiq::Worker

  def perform(_useless)
    redis = Redis.current
    res = redis.get('ActivationCallUpdateLock')
    if res.nil?
      ActivationCall.ongoing.find_each do |activation_call|
        if !activation_call.card.active? && activation_call.timeout_error?
          activation_call.failure
          activation_call.save
        end
        activation_call.update_front_end
        redis.setex('ActivationCallUpdateLock', 3, true)
        sleep 1
      end until ActivationCall.ongoing.empty?
    end
  end
end
