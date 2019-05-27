# frozen_string_literal: true

class RapidproUpdateJob
  include Sidekiq::Worker
  sidekiq_options retry: 5

  # works like so, if person has no rapidpro uuid, we post with phone,
  # otherwise use uuid. this will allow changes to phone numbers.
  # additionally, it means we only need one worker.
  def perform(id)
    Rails.logger.info '[RapidProUpdate] job enqueued'
    @person = Person.find(id)
    urn = "tel:#{@person.phone_number}"

    return RapidproDeleteJob.perform_async(id) if (@person.tag_list.include?('not dig') || @person.active == false)
    return unless @person.phone_number.present? # we may deal with a word where rapidpro does email but not now.
    body = {
      name: @person.full_name,
      first_name: @person.first_name,
      language: RapidproService.language_for_person(@person),
      urns: [urn],
      groups: ['DIG'],
      fields: { tags: RapidproService.normalize_tags(@person.tag_list) }
    }
    body[:urns] << "mailto:#{@person.email_address}" if @person.email_address.present?
    # eventual fields: # first_name: person.first_name,
    # last_name: person.last_name,
    # email_address: person.email_address,
    # zip_code: person.postal_code,
    # neighborhood: person.neighborhood,
    # patterns_token: person.token,
    # patterns_id: person.id

    query = @person&.rapidpro_uuid.present? ? { uuid: @person.rapidpro_uuid } : { urn: urn }

    @res = RapidproService.request(path: "/contacts.json", body: body, query: query)

    case @res.code
      when 201 then handle_created
      when 429 then handle_throttled
      when 200 then true
      else handle_unknown
    end
  end

  private

  def handle_created
    if @person.rapidpro_uuid.blank?
      # update column to skip callbacks
      @person.update_column(:rapidpro_uuid, @res.parsed_response['uuid'])
    end
  end

  def handle_throttled
    retry_delay = @res.headers['retry-after'].to_i + 5
    RapidproUpdateJob.perform_in(retry_delay, @person.id) # re-queue job
  end

  def handle_unknown
    raise "error: #{@res.code}"
  end
end
