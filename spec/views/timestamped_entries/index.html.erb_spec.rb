require 'spec_helper'

describe "timestamped_entries/index.html.erb" do
  before(:each) do
    assign(:timestamped_entries, [
      stub_model(TimestampedEntry),
      stub_model(TimestampedEntry)
    ])
  end

  it "renders a list of timestamped_entries" do
    render
  end
end
