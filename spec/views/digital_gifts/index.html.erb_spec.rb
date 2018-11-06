require 'rails_helper'

RSpec.describe "digital_gifts/index", type: :view do
  before(:each) do
    assign(:digital_gifts, [
      DigitalGift.create!(),
      DigitalGift.create!()
    ])
  end

  it "renders a list of digital_gifts" do
    render
  end
end
