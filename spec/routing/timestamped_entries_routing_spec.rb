require "spec_helper"

describe TimestampedEntriesController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/timestamped_entries" }.should route_to(:controller => "timestamped_entries", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/timestamped_entries/new" }.should route_to(:controller => "timestamped_entries", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/timestamped_entries/1" }.should route_to(:controller => "timestamped_entries", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/timestamped_entries/1/edit" }.should route_to(:controller => "timestamped_entries", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/timestamped_entries" }.should route_to(:controller => "timestamped_entries", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/timestamped_entries/1" }.should route_to(:controller => "timestamped_entries", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/timestamped_entries/1" }.should route_to(:controller => "timestamped_entries", :action => "destroy", :id => "1")
    end

  end
end
