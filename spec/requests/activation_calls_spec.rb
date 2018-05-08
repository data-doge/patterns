require 'rails_helper'

RSpec.describe "ActivationCalls", type: :request do
  describe "GET /activation_calls" do
    it "works! (now write some real specs)" do
      get activation_calls_path
      expect(response).to have_http_status(200)
    end
  end
end
