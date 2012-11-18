require 'spec_helper'

describe "timestamped_entries/new.html.erb" do
  before(:each) do
    assign(:timestamped_entry, stub_model(TimestampedEntry).as_new_record)
  end

  it "renders new timestamped_entry form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => timestamped_entries_path, :method => "post" do
    end
  end
end
