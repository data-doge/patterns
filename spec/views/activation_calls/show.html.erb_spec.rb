require 'rails_helper'

RSpec.describe "activation_calls/show", type: :view do
  before(:each) do
    @activation_call = assign(:activation_call, ActivationCall.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
