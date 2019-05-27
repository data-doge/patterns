# frozen_string_literal: true

class RapidproDeleteJob
  include Sidekiq::Worker
  sidekiq_options retry: 5

  def perform(id)
    Rails.logger.info '[RapidProDelete] job enqueued'
    @person = Person.unscoped.find id
    return unless @person.rapidpro_uuid.present?
    @res = RapidproService.request(method: :delete, path: "/contacts.json", query: { uuid: @person.rapidpro_uuid })

    case @res.code
      when 404 then false
      when 204, 201, 200 then handle_success
      when 429 then handle_throttled
      else handle_unknown
    end
  end

  private

  def handle_success
    @person.update_column(:rapidpro_uuid, nil) # skip callbacks
    true
  end

  def handle_throttled
    retry_delay = @res.headers['retry-after'].to_i + 5
    RapidproDeleteJob.perform_in(retry_delay, @person.id)
  end

  def handle_unknown
    raise 'RapidPro Web request Error. Is Rapidpro Up?'
  end
end
