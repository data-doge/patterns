require 'rails_helper'

RSpec.describe "activation_calls/index", type: :view do
  before(:each) do
    assign(:activation_calls, [
      ActivationCall.create!(),
      ActivationCall.create!()
    ])
  end

  it "renders a list of activation_calls" do
    render
  end
end
