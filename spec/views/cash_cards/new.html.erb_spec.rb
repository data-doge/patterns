require 'rails_helper'

RSpec.describe "cash_cards/new", type: :view do
  before(:each) do
    assign(:cash_card, CashCard.new())
  end

  it "renders new cash_card form" do
    render

    assert_select "form[action=?][method=?]", cash_cards_path, "post" do
    end
  end
end
