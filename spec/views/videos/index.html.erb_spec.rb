require 'spec_helper'

describe "videos/index.html.erb" do
  before(:each) do
    assign(:videos, [
      stub_model(Video),
      stub_model(Video)
    ])
  end

  it "renders a list of videos" do
    render
  end
end
