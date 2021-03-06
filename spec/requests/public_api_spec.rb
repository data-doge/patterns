require "rails_helper"

describe "public_api", :type => :request do
  let(:admin_user) { FactoryBot.create(:user, :admin) }
  let(:first_name) { "Doggo" }
  let(:last_name) { "Johnson" }
  let(:phone_number) { "6665551234" }
  let(:email_address) { "eugene@asdf.com" }
  let(:postal_code) { "11101" }
  let(:neighborhood) { "doggotown" }
  let(:landline) { "6667772222" }
  let(:participation_type) { "remote" }
  let(:tags) {'foo,bar,baz' }
  let(:preferred_contact_method) { { value: "SMS", label: "Text Message" } }
  let(:low_income) { true }
  let(:person) { FactoryBot.create(:person) } 
  let(:headers) {
    {
      "ACCEPT" => "application/json",
      "HTTP_ACCEPT" => "application/json",
      'AUTHORIZATION' => admin_user.token
    }
  }

  let(:invalid_headers) {
    {
      "ACCEPT" => "application/json",
      "HTTP_ACCEPT" => "application/json",
      'AUTHORIZATION' => 'bustedauthtoken'
    }
  }
  context 'valid auth token' do
    it "creates person through the API" do
      post "/api/create_person", params: {:tags => tags,
                                          :first_name => first_name,
                                          :last_name => last_name,
                                          :preferred_contact_method => 'SMS',
                                          :postal_code => postal_code,
                                          :email_address => email_address,
                                          :low_income => true,
                                          :phone_number => phone_number,},
                                          headers: headers

      expect(response.content_type).to eq("application/json")
      expect(response).to have_http_status(:created)

      expect(Person.last.first_name).to eq('Doggo')
    end

    it "updates person through API" do
      post "/api/update_person", 
            params: { phone_number: person.phone_number, 
                      tags:'bat,bonk',
                      note:'this is a note',
                      first_name: 'Pupper'
                    },
            headers: headers
      expect(response.content_type).to eq("application/json")
      
      person.reload
      expect(person.first_name).to_not eq('Doggo')
      expect(person.first_name).to eq('Pupper')
      expect(person.comments.size).to eq(1)
      expect(person.comments.last.content).to include 'note'
      expect(person.tag_list).to include('bat')
    end

    it 'gets a person from the api' do
      get "/api/show.json",
          params: {phone_number: person.phone_number},
          headers: headers

      expect(response.status).to eq(200)
      resp_json = JSON.parse(response.body)
      expect(resp_json).to eq(JSON.parse(person.to_json))
    end
  end

  context 'invalid auth token' do
    it "cannot create a person through the API" do
      post "/api/create_person", params: {:tags => tags,
                                          :first_name => first_name,
                                          :last_name => last_name,
                                          :preferred_contact_method => 'SMS',
                                          :postal_code => postal_code,
                                          :email_address => email_address,
                                          :low_income => true,
                                          :phone_number => phone_number,},
                                          headers: invalid_headers

      expect(response.content_type).to eq("text/html")
      expect(response).to have_http_status(:not_found)
    end
    
    it 'cannot update a person' do
      post "/api/update_person", 
            params: { phone_number: person.phone_number, 
                      tags:'bat,bonk',
                      note:'this is a note',
                      first_name: 'Pupper'
                    },
            headers: invalid_headers

      expect(response.content_type).to eq("text/html")
      expect(response.status).to eq(404)
      person.reload
      expect(person.first_name).to_not eq('pupper')
      expect(person.tag_list).to_not include('bat')
    end

    it 'cannot get person info' do
      get "/api/show.json", 
          params: {phone_number: person.phone_number},
          headers: invalid_headers

      expect(response.status).to_not eq(200)
      expect(response.status).to eq(404)
    end
  end
end
