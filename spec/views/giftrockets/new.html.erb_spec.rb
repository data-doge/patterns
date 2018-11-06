require 'rails_helper'

RSpec.describe "giftrockets/new", type: :view do
  before(:each) do
    assign(:giftrocket, DigitalGift.new())
  end

  it "renders new giftrocket form" do
    render

    assert_select "form[action=?][method=?]", giftrockets_path, "post" do
    end
  end
end
