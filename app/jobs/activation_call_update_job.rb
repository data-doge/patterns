# frozen_string_literal: true

class ActivationCallUpdateJob
  include Sidekiq::Worker

  def perform(_useless)
    redis = Redis.current
    res = redis.get('ActivationCallUpdateLock')
    if res.nil?
      ActivationCall.ongoing.find_each do |activation_call|
        if activation_call.timeout_error?
          activation_call.failure
          activation_call.save
          activation_call.update_front_end
        end
        redis.setex('ActivationCallUpdateLock', 5, true)
        sleep 1
      end until ActivationCall.ongoing.empty?
    end
  end
end
