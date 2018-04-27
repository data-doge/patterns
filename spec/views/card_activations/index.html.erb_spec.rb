require 'rails_helper'

RSpec.describe "card_activations/index", type: :view do
  before(:each) do
    assign(:card_activations, [
      CardActivation.create!(),
      CardActivation.create!()
    ])
  end

  it "renders a list of card_activations" do
    render
  end
end
