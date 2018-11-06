require 'rails_helper'

RSpec.describe "giftrockets/index", type: :view do
  before(:each) do
    assign(:giftrockets, [
      DigitalGift.create!(),
      DigitalGift.create!()
    ])
  end

  it "renders a list of giftrockets" do
    render
  end
end
