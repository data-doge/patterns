require 'rails_helper'

RSpec.describe "digital_gifts/new", type: :view do
  before(:each) do
    assign(:digital_gift, DigitalGift.new())
  end

  it "renders new digital_gift form" do
    render

    assert_select "form[action=?][method=?]", digital_gifts_path, "post" do
    end
  end
end
