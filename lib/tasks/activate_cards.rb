require_relative "../../config/boot"
require_relative "../../config/environment"
require 'csv'
@client = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])

csv_text = File.read('../../cards.csv')
csv = CSV.parse(csv_text, :headers => true)
csv.each do |row|
  number = row['number']
  code   = row['code']
  url = "https://#{ENV['PRODUCTION_SERVER']}/gift_cards/activate.xml?number=#{number}&code=#{code}"
  @call = @client.account.calls.create(
    from: ENV['TWILIO_SCHEDULING_NUMBER'],   # From your Twilio number
    to: '+18663008288', # BOA activation number
    # Fetch instructions from this URL when the call connects
    url: url,
    method: "GET" )
end

