# frozen_string_literal: true

class RapidproService
  REQUEST_HEADERS = { 'Authorization' => "Token #{ENV['RAPIDPRO_TOKEN']}", 'Content-Type' => 'application/json' }
  BASE_URL = 'https://rapidpro.brl.nyc/api/v2'

  class << self
    def language_for_person(person)
      { es: 'spa', zh: 'chi' }[person.locale.to_sym] || 'eng'
    end

    # rapidpro tags are space delimited and have underscores for spaces
    def normalize_tags(tags)
      tags.map { |t| t.tr(' ', '_') }.join(' ')
    end

    def request(method:, path:, body: {}, query: {})
      url = "#{BASE_URL}#{path}"
      url += "?#{query.to_query}" unless query.empty?
      params = { headers: REQUEST_HEADERS }
      params[:body] = body.to_json unless body.empty?
      HTTParty.send(method, url, **params)
    end
  end
end
