require 'rails_helper'

RSpec.describe "CardActivations", type: :request do
  describe "GET /card_activations" do
    it "works! (now write some real specs)" do
      get card_activations_path
      expect(response).to have_http_status(200)
    end
  end
end
