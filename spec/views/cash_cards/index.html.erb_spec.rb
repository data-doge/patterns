require 'rails_helper'

RSpec.describe "cash_cards/index", type: :view do
  before(:each) do
    assign(:cash_cards, [
      CashCard.create!(),
      CashCard.create!()
    ])
  end

  it "renders a list of cash_cards" do
    render
  end
end
