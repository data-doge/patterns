# frozen_string_literal: true

class RapidproGroupJob
  include Sidekiq::Worker
  sidekiq_options retry: 5

  # works like so, if person has no rapidpro uuid, we post with phone,
  # otherwise use uuid. this will allow changes to phone numbers.
  # additionally, it means we only need one worker.
  def perform(id)
    headers = { 'Authorization' => "Token #{ENV['RAPIDPRO_TOKEN']}",
                'Content-Type'  => 'application/json' }
    base_url = 'https://rapidpro.brl.nyc/api/v2/'

    Rails.logger.info '[RapidProGroup] job enqueued'

    cart = Cart.find(id)

    # cart isn't in rapidpro
    if cart&.rapidpro_uuid.nil?
      # create group and save uuid
      url = base_url + 'groups.json'
      res = HTTParty.post(url, headers: headers, body: { name: cart.name }.to_json)
      case res.code
      when 201 || 200 || 204# new group in rapidpro
        # update column to skip callbacks
        cart.update_column(:rapidpro_uuid, res.parsed_response['uuid'])
      when 429 # throttled
        retry_delay = res.headers['retry-after'].to_i + 5
        RapidproGroupJob.perform_in(retry_delay, id) # re-queue job
      else
        Rails.logger.error res.code
        raise 'error'
      end
    end
    if cart.people.positive?
      uuids = cart.people.where.not(rapidpro_uuid: nil, phone_number: nil).pluck(:rapidpro_uuid)
      body = { contacts: uuids, action: 'add', group: cart.rapidpro_uuid }
      url = base_url + 'contact_actions.json' # bulk actions

      res = HTTParty.post(url, headers: headers, body: body.to_json)

      case res.code
      when 201 || 200 || 204 # new person in rapidpro
        return true
      when 429 # throttled
        retry_delay = res.headers['retry-after'].to_i + 5
        RapidproGroupJob.perform_in(retry_delay, id) # re-queue job
      else
        Rails.logger.error res.code
        raise 'error'
      end
    end
  end
end
