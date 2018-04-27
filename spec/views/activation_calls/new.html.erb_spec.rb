require 'rails_helper'

RSpec.describe "activation_calls/new", type: :view do
  before(:each) do
    assign(:activation_call, ActivationCall.new())
  end

  it "renders new activation_call form" do
    render

    assert_select "form[action=?][method=?]", activation_calls_path, "post" do
    end
  end
end
