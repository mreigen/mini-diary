require "spec_helper"

describe VideosController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/videos" }.should route_to(:controller => "videos", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/videos/new" }.should route_to(:controller => "videos", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/videos/1" }.should route_to(:controller => "videos", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/videos/1/edit" }.should route_to(:controller => "videos", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/videos" }.should route_to(:controller => "videos", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/videos/1" }.should route_to(:controller => "videos", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/videos/1" }.should route_to(:controller => "videos", :action => "destroy", :id => "1")
    end

  end
end
