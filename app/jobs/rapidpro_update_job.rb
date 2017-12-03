# rubocop:disable Style/StructInheritance
class RapidProUpdateJob < Struct.new(:id)

  def enqueue(job)
    Rails.logger.info '[RapidProUpdate] job enqueued'
    job.save!
  end

  def perform
    person = Person.find id
    if person&.phone_number.present?
      urn = CGI::escape("tel:#{person.phone_number}")
      res = HTTParty.post("https://rapidpro.brl.nyc/api/v2/contacts.json?urn=#{urn}",
        headers: { 'Authorization' => "Token #{ENV['RAPIDPRO_TOKEN']}",
                   'Content-Type'=> 'application/json' },
        body: { name: person.full_name,
                language: 'eng',
                groups: [],
                fields: {
                  # first_name: person.first_name,
                  # last_name: person.last_name,
                  # email_address: person.email_address,
                  # zip_code: person.postal_code,
                  # neighborhood: person.neighborhood,
                  # patterns_token: person.token,
                  # patterns_id: person.id
                }}.to_json)
      case res.code
      when 404 # this person doesn't exist in rapidpro, create them
        Delayed::Job.enqueue(RapidProCreateJob.new(id)).save
      else
        raise "error"
      end
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
