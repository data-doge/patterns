require 'rails_helper'

RSpec.describe "card_activations/show", type: :view do
  before(:each) do
    @card_activation = assign(:card_activation, CardActivation.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
