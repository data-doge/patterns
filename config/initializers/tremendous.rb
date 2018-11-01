require 'tremendous'
Tremendous.configure do |config|
  config[:access_token] = ENV['TREMENDOUS_API_KEY']
  config[:base_api_uri] = ENV['TREMENDOUS_API_ENDPOINT']
end
