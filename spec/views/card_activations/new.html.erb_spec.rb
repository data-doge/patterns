require 'rails_helper'

RSpec.describe "card_activations/new", type: :view do
  before(:each) do
    assign(:card_activation, CardActivation.new())
  end

  it "renders new card_activation form" do
    render

    assert_select "form[action=?][method=?]", card_activations_path, "post" do
    end
  end
end
