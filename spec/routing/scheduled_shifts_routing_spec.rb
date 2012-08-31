require "spec_helper"

describe ScheduledShiftsController do
  describe "routing" do

    it "routes to #index" do
      get("/scheduled_shifts").should route_to("scheduled_shifts#index")
    end

    it "routes to #new" do
      get("/scheduled_shifts/new").should route_to("scheduled_shifts#new")
    end

    it "routes to #show" do
      get("/scheduled_shifts/1").should route_to("scheduled_shifts#show", :id => "1")
    end

    it "routes to #edit" do
      get("/scheduled_shifts/1/edit").should route_to("scheduled_shifts#edit", :id => "1")
    end

    it "routes to #create" do
      post("/scheduled_shifts").should route_to("scheduled_shifts#create")
    end

    it "routes to #update" do
      put("/scheduled_shifts/1").should route_to("scheduled_shifts#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/scheduled_shifts/1").should route_to("scheduled_shifts#destroy", :id => "1")
    end

  end
end
