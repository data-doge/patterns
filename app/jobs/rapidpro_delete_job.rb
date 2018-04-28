# frozen_string_literal: true

# rubocop:disable Style/StructInheritance
class RapidproDeleteJob < Struct.new(:id)
  attr_accessor :retry_delay
  attr_accessor :id

  def initialize(id)
    self.id = id
    self.retry_delay = 5 # default retry delay
  end

  def enqueue(job)
    Rails.logger.info '[RapidProDelete] job enqueued'
    job.save!
  end

  def perform
    person = Person.find id
    if person&.rapidpro_uuid.present?
      headers = { 'Authorization' => "Token #{ENV['RAPIDPRO_TOKEN']}",
                  'Content-Type'  => 'application/json' }
      url = "https://rapidpro.brl.nyc/api/v2/contacts.json?uuid=#{person.rapidpro_uuid}"
      res = HTTParty.delete(url, headers: headers)

      case res.code
      when 404
        return false
      when 204 || 201 || 200 # successful delete
        person.update_column(:rapidpro_uuid, nil) # skip callbacks
        return true
      when 429
        self.retry_delay = res.headers['retry-after'].to_i
        raise 'error'
      else
        raise 'error'
      end
    end
  end

  def max_attempts
    15
  end

  def reschedule_at(current_time, attempts)
    # rapidpro gives us a retry time. We pad with attempts
    current_time + (retry_delay + attempts).seconds
  end
end
# rubocop:enable Style/StructInheritance
