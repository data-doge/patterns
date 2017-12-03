# rubocop:disable Style/StructInheritance
class RapidproUpdateJob < Struct.new(:id)

  def enqueue(job)
    Rails.logger.info '[RapidProUpdate] job enqueued'
    job.save!
  end

  # works like so, if person has no rapidpro uuid, we post with phone,
  # otherwise use uuid. this will allow changes to phone numbers.
  # additionally, it means we only need one worker.
  def perform
    person = Person.where(id: id).not(phone_number: nil)
    base_url = 'https://rapidpro.brl.nyc/api/v2/contacts.json'

    body = { name: person.full_name, language: 'eng', groups: [], fields: {} }
    # eventual fields: # first_name: person.first_name,
    # last_name: person.last_name,
    # email_address: person.email_address,
    # zip_code: person.postal_code,
    # neighborhood: person.neighborhood,
    # patterns_token: person.token,
    # patterns_id: person.id

    urn = "tel:#{person.phone_number}"

    if person&.rapidpro_uuid.present? # already created in rapidpro
      url = base_url + "?uuid=#{person.rapidpro_uuid}"
      body[:urns] = [urn] # adds new phone number if need be.
    else # person doesn't yet exist in rapidpro
      cgi_urn = CGI::escape(urn)
      url = base_url + "?urn=#{cgi_urn}" # uses phone number to identify.
    end

    headers = { 'Authorization' => "Token #{ENV['RAPIDPRO_TOKEN']}",
                'Content-Type'  => 'application/json' }

    res = HTTParty.post(url, headers: headers, body: body.to_json)

    if res.code == 200
      # skip callbacks
      if person.rapidpro_uuid.blank?
        person.update_column(:rapidpro_uuid, res.parsed_response['uuid'])
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
