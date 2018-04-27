require "rails_helper"

RSpec.describe CardActivationsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/card_activations").to route_to("card_activations#index")
    end

    it "routes to #new" do
      expect(:get => "/card_activations/new").to route_to("card_activations#new")
    end

    it "routes to #show" do
      expect(:get => "/card_activations/1").to route_to("card_activations#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/card_activations/1/edit").to route_to("card_activations#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/card_activations").to route_to("card_activations#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/card_activations/1").to route_to("card_activations#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/card_activations/1").to route_to("card_activations#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/card_activations/1").to route_to("card_activations#destroy", :id => "1")
    end

  end
end
