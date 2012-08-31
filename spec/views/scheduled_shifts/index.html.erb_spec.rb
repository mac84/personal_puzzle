require 'spec_helper'

describe "scheduled_shifts/index" do
  before(:each) do
    assign(:scheduled_shifts, [
      stub_model(ScheduledShift,
        :task_id => 1,
        :duration => 2
      ),
      stub_model(ScheduledShift,
        :task_id => 1,
        :duration => 2
      )
    ])
  end

  it "renders a list of scheduled_shifts" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
  end
end
