require_relative "../../config/boot"
require_relative "../../config/environment"
require 'csv'
@client = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])

csv_text = File.read('../../cards.csv')
csv = CSV.parse(csv_text, :headers => true)
csv.each do |row|
  number = row['number']
  code   = row['code']
  next if code.nil?
  url = "https://#{ENV['PRODUCTION_SERVER']}/activate/#{number.chop}/#{code.to_s.chop}.xml"
  @call = @client.account.calls.create(
    from: ENV['TWILIO_SCHEDULING_NUMBER'],   # From your Twilio number
    to: '+18663008288', # BOA activation number
    # Fetch instructions from this URL when the call connects
    url: url,
    method: "GET" )
end
