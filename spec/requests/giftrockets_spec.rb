require 'rails_helper'

RSpec.describe "Giftrockets", type: :request do
  describe "GET /giftrockets" do
    it "works! (now write some real specs)" do
      get giftrockets_path
      expect(response).to have_http_status(200)
    end
  end
end
