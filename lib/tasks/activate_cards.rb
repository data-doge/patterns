require_relative "../../config/boot"
require_relative "../../config/environment"

@client ||= $twilio

def activate
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
      puts "card not activated: #{card_number} transcript: #{transcript.nil? ? 'nil' : transcript}"
    end
  end
end

def check
  csv_text = File.read('cards.csv')
  csv = CSV.parse(csv_text, :headers => true)
  @calls = {}
  csv.each do |row|
    number = row[0]
    code   = row[1]
    expiration = row[2]
    next if code.nil? || number.nil? || expiration.nil?
    if code.length != 3
      puts "invalid code: #{number},#{code}"
      next
    end

    cc = CreditCardValidations::Detector.new(number)
    unless cc.valid? && cc.valid_luhn?
      puts "invalid credit card number: #{number},#{code}"
    end

    url = "https://#{ENV['PRODUCTION_SERVER']}/card_check/#{number.to_s}/#{code.to_s}/#{expiration.to_s}.xml"

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
    end
    if @not_completed == true
      puts "not done yet, sleeping"
      sleep 10
    end
  end
  @active = 0
  @calls.each do |card_number,c|

    c.update
    transcript = c&.recordings&.list&.first&.transcriptions&.list&.first&.transcription_text
    
    if transcript.nil? || !transcript.include?('Please hold while')
      puts "card not activated: #{card_number} transcript: #{transcript.nil? ? 'nil' : transcript}"
    else
      puts "activated!"
      @active +=1
  end

end
