# rubocop:disable Style/StructInheritance
class RapidproDeleteJob < Struct.new(:id)

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

      person.update_column(:rapidpro_uuid, nil) # skip callbacks
      return if res.code == 404 # not found
      raise 'error' if res.code != 204 # success
    end
  end

  def max_attempts
    5
  end

  def reschedule_at(current_time, attempts)
    current_time + (5 * attempts).seconds
  end
end
# rubocop:enable Style/StructInheritance
