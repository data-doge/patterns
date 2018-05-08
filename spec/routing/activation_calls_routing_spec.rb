require "rails_helper"

RSpec.describe ActivationCallsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/activation_calls").to route_to("activation_calls#index")
    end

    it "routes to #new" do
      expect(:get => "/activation_calls/new").to route_to("activation_calls#new")
    end

    it "routes to #show" do
      expect(:get => "/activation_calls/1").to route_to("activation_calls#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/activation_calls/1/edit").to route_to("activation_calls#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/activation_calls").to route_to("activation_calls#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/activation_calls/1").to route_to("activation_calls#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/activation_calls/1").to route_to("activation_calls#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/activation_calls/1").to route_to("activation_calls#destroy", :id => "1")
    end

  end
end
