require 'spec_helper'

describe "scheduled_shifts/show" do
  before(:each) do
    @scheduled_shift = assign(:scheduled_shift, stub_model(ScheduledShift,
      :task_id => 1,
      :duration => 2
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    rendered.should match(/2/)
  end
end
