require 'rails_helper'

RSpec.describe "CashCards", type: :request do
  describe "GET /cash_cards" do
    it "works! (now write some real specs)" do
      get cash_cards_path
      expect(response).to have_http_status(200)
    end
  end
end
