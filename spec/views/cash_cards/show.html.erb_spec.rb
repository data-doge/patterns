require 'rails_helper'

RSpec.describe "cash_cards/show", type: :view do
  before(:each) do
    @cash_card = assign(:cash_card, CashCard.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
