require 'spec_helper'

describe "scheduled_shifts/new" do
  before(:each) do
    assign(:scheduled_shift, stub_model(ScheduledShift,
      :task_id => 1,
      :duration => 1
    ).as_new_record)
  end

  it "renders new scheduled_shift form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => scheduled_shifts_path, :method => "post" do
      assert_select "input#scheduled_shift_task_id", :name => "scheduled_shift[task_id]"
      assert_select "input#scheduled_shift_duration", :name => "scheduled_shift[duration]"
    end
  end
end
