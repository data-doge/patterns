require 'rails_helper'

RSpec.describe "giftrockets/edit", type: :view do
  before(:each) do
    @giftrocket = assign(:giftrocket, DigitalGift.create!())
  end

  it "renders the edit giftrocket form" do
    render

    assert_select "form[action=?][method=?]", giftrocket_path(@giftrocket), "post" do
    end
  end
end
