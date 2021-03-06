require "rails_helper"

RSpec.describe RapidproService do
  let(:sut) { RapidproService }

  describe "#language_for_person(person)" do
    it "works" do
      person = FactoryBot.create(:person)
      person.update(locale: "en")
      expect(sut.language_for_person(person)).to eq('eng')
      person.update(locale: "es")
      expect(sut.language_for_person(person)).to eq('spa')
      person.update(locale: "zh")
      expect(sut.language_for_person(person)).to eq('chi')
      person.update(locale: "DOG")
      expect(sut.language_for_person(person)).to eq('eng')
    end
  end
end
