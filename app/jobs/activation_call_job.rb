# frozen_string_literal: true

# rubocop:disable Style/StructInheritance
class ActivationCallJob < Struct.new(:id)
  attr_accessor :retry_delay
  attr_accessor :id

  def initialize(id)
    self.id = id
    self.retry_delay = 5 # default retry delay
  end

  def enqueue(job)
    Rails.logger.info '[ActivationCall] job enqueued'
    job.save!
  end

  # how it works: sends a twilio call, and records the sid, etc in the call object
  def perform
    call = ActivationCall.find(id)
    card = call.card_activation
    case call.call_type # activation or check for now. soon balance.
    when 'activate'
      url = "https://#{HOSTNAME}/activation_calls/activate/#{call.token}.xml"
    when 'check'
      url = "https://#{HOSTNAME}/activation_calls/check/#{call.token}.xml"
    end
    res = $twilio.account.calls.create(
      from: ENV['TWILIO_SCHEDULING_NUMBER'],   # From your Twilio number
      to: '+18663008288', # BOA activation number
      # Fetch instructions from this URL when the call connects
      url: url,
      method: 'GET')

    call.sid = res.sid
    call.save!
  end

  def max_attempts
    5
  end

  def reschedule_at(current_time, _attempts)
    current_time + (retry_delay + attemps).seconds
  end

end
# rubocop:enable Style/StructInheritance
