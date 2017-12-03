# rubocop:disable Style/StructInheritance
class RapidproUpdateJob < Struct.new(:id)
  attr_accessor :retry_delay

  def initialize
    self.retry_delay = 5 # default retry delay
  end


  def enqueue(job)
    Rails.logger.info '[RapidProUpdate] job enqueued'
    job.save!
  end

  # works like so, if person has no rapidpro uuid, we post with phone,
  # otherwise use uuid. this will allow changes to phone numbers.
  # additionally, it means we only need one worker.
  def perform
    person = Person.find(id)
    # we may deal with a word where rapidpro does email...
    # but not now.
    if person.phone_number.present?
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
        body[:urns] << "mailto:#{person.email_address}" if person.email_address.present?
      else # person doesn't yet exist in rapidpro
        cgi_urn = CGI::escape(urn)
        url = base_url + "?urn=#{cgi_urn}" # uses phone number to identify.
      end

      headers = { 'Authorization' => "Token #{ENV['RAPIDPRO_TOKEN']}",
                  'Content-Type'  => 'application/json' }

      res = HTTParty.post(url, headers: headers, body: body.to_json)

      case res.code
      when 201 || 204 || 200 # new person in rapidpro
        if person.rapidpro_uuid.blank?
          # update column to skip callbacks
          person.update_column(:rapidpro_uuid, res.parsed_response['uuid'])
        end
      when 429 # throttled
        self.retry_delay = res.headers['retry-after'].to_i
      else
        raise 'error'
      end
    end
  end

  def max_attempts
    15
  end

  def reschedule_at(current_time, attempts)
    current_time + (retry_delay + attemps).seconds
  end

end
# rubocop:enable Style/StructInheritance
