require "rails_helper"

RSpec.describe RapidproDeleteJob, :type => :job do
  let(:sut) { RapidproDeleteJob }
  let(:person) { FactoryBot.create(:person, :rapidpro_syncable) }
  let(:action) { sut.new.perform(person.id) }
  let(:rapidpro_headers) { { 'Authorization' => "Token #{ENV['RAPIDPRO_TOKEN']}", 'Content-Type'  => 'application/json' } }

  context "rapidpro_uuid not present" do
    before { person.update(rapidpro_uuid: nil) }

    it "doesnt do anything" do
      expect(HTTParty).not_to receive(:send)
      expect(action).to be_nil
    end
  end

  context "rapidpro returns 404" do
    it "returns false and doesnt do anything" do
      expect(HTTParty).to receive(:send).with(
        :delete,
        "https://rapidpro.brl.nyc/api/v2/contacts.json?uuid=#{person.rapidpro_uuid}",
        headers: rapidpro_headers
      ).and_return(Hashie::Mash.new({
        code: 404
      }))
      expect(action).to eq(false)
    end
  end

  context "rapidpro returns 204" do
    it "updates rapidpro_uuid to nil and returns true" do
      expect(HTTParty).to receive(:send).with(
        :delete,
        "https://rapidpro.brl.nyc/api/v2/contacts.json?uuid=#{person.rapidpro_uuid}",
        headers: rapidpro_headers
      ).and_return(Hashie::Mash.new({
        code: 204
      }))
      expect(action).to eq(true)
      expect(person.reload.rapidpro_uuid).to be_nil
    end
  end

  context "rapidpro returns 201" do
    it "updates rapidpro_uuid to nil and returns true" do
      expect(HTTParty).to receive(:send).with(
        :delete,
        "https://rapidpro.brl.nyc/api/v2/contacts.json?uuid=#{person.rapidpro_uuid}",
        headers: rapidpro_headers
      ).and_return(Hashie::Mash.new({
        code: 201
      }))
      expect(action).to eq(true)
      expect(person.reload.rapidpro_uuid).to be_nil
    end
  end

  context "rapidpro returns 200" do
    it "updates rapidpro_uuid to nil and returns true" do
      expect(HTTParty).to receive(:send).with(
        :delete,
        "https://rapidpro.brl.nyc/api/v2/contacts.json?uuid=#{person.rapidpro_uuid}",
        headers: rapidpro_headers
      ).and_return(Hashie::Mash.new({
        code: 200
      }))
      expect(action).to eq(true)
      expect(person.reload.rapidpro_uuid).to be_nil
    end
  end

  context "rapidpro returns 429" do
    it "re-queues job" do
      expect(HTTParty).to receive(:send).with(
        :delete,
        "https://rapidpro.brl.nyc/api/v2/contacts.json?uuid=#{person.rapidpro_uuid}",
        headers: rapidpro_headers
      ).and_return(Hashie::Mash.new({
        code: 429,
        headers: {
          'retry-after' => 100
        }
      }))
      expect(sut).to receive(:perform_in).with(100 + 5, person.id)
      action
      expect(person.reload.rapidpro_uuid).not_to be_nil
    end
  end

  context "rapidpro returns unknown response" do
    it "raises error" do
      expect(HTTParty).to receive(:send).with(
        :delete,
        "https://rapidpro.brl.nyc/api/v2/contacts.json?uuid=#{person.rapidpro_uuid}",
        headers: rapidpro_headers
      ).and_return(Hashie::Mash.new({
        code: 666
      }))
      expect { action }.to raise_error(RuntimeError)
    end
  end
end
