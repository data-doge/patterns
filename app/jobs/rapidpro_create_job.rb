# rubocop:disable Style/StructInheritance
class RapidProCreateJob < Struct.new(:id)

  def enqueue(job)
    Rails.logger.info '[RapidProCreate] job enqueued'
    job.save!
  end

  def perform
    person = Person.find id
    if person&.phone_number.present?
      res = HTTParty.post('https://rapidpro.brl.nyc/api/v2/contacts.json',
        headers: { 'Authorization' => "Token #{ENV['RAPIDPRO_TOKEN']}",
                   'Content-Type'=> 'application/json' },
        body: { name: person.full_name,
                urns: ["tel:#{person.phone_number}"],
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
    when 400 # this person already exists in rapidpro
      Delayed::Job.enqueue(RapidProUpdateJob.new(id)).save
    else
      raise "error"
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
