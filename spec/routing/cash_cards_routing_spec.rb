require "rails_helper"

RSpec.describe CashCardsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/cash_cards").to route_to("cash_cards#index")
    end

    it "routes to #new" do
      expect(:get => "/cash_cards/new").to route_to("cash_cards#new")
    end

    it "routes to #show" do
      expect(:get => "/cash_cards/1").to route_to("cash_cards#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/cash_cards/1/edit").to route_to("cash_cards#edit", :id => "1")
    end


    it "routes to #create" do
      expect(:post => "/cash_cards").to route_to("cash_cards#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/cash_cards/1").to route_to("cash_cards#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/cash_cards/1").to route_to("cash_cards#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/cash_cards/1").to route_to("cash_cards#destroy", :id => "1")
    end
  end
end
