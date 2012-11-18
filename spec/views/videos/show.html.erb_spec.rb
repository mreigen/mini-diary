require 'spec_helper'

describe "videos/show.html.erb" do
  before(:each) do
    @video = assign(:video, stub_model(Video))
  end

  it "renders attributes in <p>" do
    render
  end
end
