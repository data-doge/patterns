require 'rails_helper'

RSpec.describe "digital_gifts/edit", type: :view do
  before(:each) do
    @digital_gift = assign(:digital_gift, DigitalGift.create!())
  end

  it "renders the edit digital_gift form" do
    render

    assert_select "form[action=?][method=?]", digital_gift_path(@digital_gift), "post" do
    end
  end
end
