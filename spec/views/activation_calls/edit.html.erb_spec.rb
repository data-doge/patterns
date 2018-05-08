require 'rails_helper'

RSpec.describe "activation_calls/edit", type: :view do
  before(:each) do
    @activation_call = assign(:activation_call, ActivationCall.create!())
  end

  it "renders the edit activation_call form" do
    render

    assert_select "form[action=?][method=?]", activation_call_path(@activation_call), "post" do
    end
  end
end
