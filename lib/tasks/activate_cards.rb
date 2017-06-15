require_relative "../../config/boot"
require_relative "../../config/environment"
require 'csv'
@client = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])

csv_text = File.read('cards.csv')
csv = CSV.parse(csv_text, :headers => true)
@calls = {}
csv.each do |row|
  number = row['number']
  code   = row['code']
  next if code.nil?
  url = "https://#{ENV['PRODUCTION_SERVER']}/activate/#{number.to_s}/#{code.to_s}.xml"

  @calls[number] = @client.account.calls.create(
    from: ENV['TWILIO_SCHEDULING_NUMBER'],   # From your Twilio number
    to: '+18663008288', # BOA activation number
    # Fetch instructions from this URL when the call connects
    url: url,
    method: "GET" )
end
not_completed = true
while not_completed == true
  not_completed = false
  @calls.each do |k,v|
    v.update
    not_completed = true if v.status != 'completed'
  end
  sleep 5 if not_completed == true
end
# how to get a transcription
#call.recordings.list.first.transcriptions.list.first.transcription_text
