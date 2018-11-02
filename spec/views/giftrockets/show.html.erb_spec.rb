require 'rails_helper'

RSpec.describe "giftrockets/show", type: :view do
  before(:each) do
    @giftrocket = assign(:giftrocket, Giftrocket.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
