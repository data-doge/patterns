require 'rails_helper'

RSpec.describe "card_activations/edit", type: :view do
  before(:each) do
    @card_activation = assign(:card_activation, CardActivation.create!())
  end

  it "renders the edit card_activation form" do
    render

    assert_select "form[action=?][method=?]", card_activation_path(@card_activation), "post" do
    end
  end
end
