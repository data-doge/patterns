require_relative "../../config/boot"
require_relative "../../config/environment"

@client = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])

@call = @client.account.calls.create(
  from: ENV['TWILIO_SCHEDULING_NUMBER'],   # From your Twilio number
  to: '+18663008288', # BOA activation number
  # Fetch instructions from this URL when the call connects
  url: "https://#{ENV['PRODUCTION_SERVER']}/activate.xml",
  method: "GET"
)
