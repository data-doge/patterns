require 'rails_helper'

RSpec.describe "giftrockets/index", type: :view do
  before(:each) do
    assign(:giftrockets, [
      Giftrocket.create!(),
      Giftrocket.create!()
    ])
  end

  it "renders a list of giftrockets" do
    render
  end
end
