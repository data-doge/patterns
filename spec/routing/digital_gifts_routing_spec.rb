require "rails_helper"

RSpec.describe DigitalGiftsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/giftrockets").to route_to("giftrockets#index")
    end

    it "routes to #new" do
      expect(:get => "/giftrockets/new").to route_to("giftrockets#new")
    end

    it "routes to #show" do
      expect(:get => "/giftrockets/1").to route_to("giftrockets#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/giftrockets/1/edit").to route_to("giftrockets#edit", :id => "1")
    end


    it "routes to #create" do
      expect(:post => "/giftrockets").to route_to("giftrockets#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/giftrockets/1").to route_to("giftrockets#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/giftrockets/1").to route_to("giftrockets#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/giftrockets/1").to route_to("giftrockets#destroy", :id => "1")
    end
  end
end
