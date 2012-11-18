require 'spec_helper'

describe "timestamped_entries/show.html.erb" do
  before(:each) do
    @timestamped_entry = assign(:timestamped_entry, stub_model(TimestampedEntry))
  end

  it "renders attributes in <p>" do
    render
  end
end
