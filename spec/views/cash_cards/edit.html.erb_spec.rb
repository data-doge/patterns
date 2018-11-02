require 'rails_helper'

RSpec.describe "cash_cards/edit", type: :view do
  before(:each) do
    @cash_card = assign(:cash_card, CashCard.create!())
  end

  it "renders the edit cash_card form" do
    render

    assert_select "form[action=?][method=?]", cash_card_path(@cash_card), "post" do
    end
  end
end
