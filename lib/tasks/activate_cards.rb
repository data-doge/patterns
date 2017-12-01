require_relative "../../config/boot"
require_relative "../../config/environment"
require 'csv'
@client = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])

csv_text = File.read('cards.csv')
csv = CSV.parse(csv_text, :headers => true)
@calls = {}
csv.each do |row|
  number = row[0]
  code   = row[1]
  next if code.nil? && number.nil?
  if code.length != 3
    puts "invalid code: #{number},#{code}"
    next
  end

  cc = CreditCardValidations::Detector.new(number)
  unless cc.valid? && cc.valid_luhn?
    puts "invalid credit card number: #{number},#{code}"
  end

  url = "https://#{ENV['PRODUCTION_SERVER']}/activate/#{number.to_s}/#{code.to_s}.xml"

  @calls[number] = @client.account.calls.create(
    from: ENV['TWILIO_SCHEDULING_NUMBER'],   # From your Twilio number
    to: '+18663008288', # BOA activation number
    # Fetch instructions from this URL when the call connects
    url: url,
    method: "GET" )
end

@not_completed = true
while @not_completed == true
  @not_completed = false
  @calls.each do |k,v|
    if v.status != 'completed'
      v.update
      @not_completed = true
      puts v.status
    end

    if v.status == 'no-answer'
      @not_completed = true
      row = csv.find {|c| c['number'] == k }
      number = row['number']
      code = row['code']
      url = "https://#{ENV['PRODUCTION_SERVER']}/activate/#{number.to_s}/#{code.to_s}.xml"

      @calls[number] = @client.account.calls.create(
        from: ENV['TWILIO_SCHEDULING_NUMBER'],   # From your Twilio number
        to: '+18663008288', # BOA activation number
        # Fetch instructions from this URL when the call connects
        url: url,
        method: "GET" )
      puts "calling again for #{number}, #{code}"
    end
  end
  if @not_completed == true
    puts "not done yet, sleeping"
    sleep 10
  end
end
# how to get a transcription
@calls.each do |card_number,c|
  c.update
  transcript = c&.recordings&.list&.first&.transcriptions&.list&.first&.transcription_text
  # "Your pin has been created your card has been activated"
  if transcript.nil? || !transcript.include?('Your pin has been created')
    puts "card not activated: #{card_number}"
    puts transcript
  end
end
