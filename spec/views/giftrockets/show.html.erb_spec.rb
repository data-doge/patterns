require 'rails_helper'

RSpec.describe "giftrockets/show", type: :view do
  before(:each) do
    @giftrocket = assign(:giftrocket, DigitalGift.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
