require 'spec_helper'

describe "timestamped_entries/edit.html.erb" do
  before(:each) do
    @timestamped_entry = assign(:timestamped_entry, stub_model(TimestampedEntry))
  end

  it "renders the edit timestamped_entry form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => timestamped_entries_path(@timestamped_entry), :method => "post" do
    end
  end
end
