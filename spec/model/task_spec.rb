require File.dirname(__FILE__) + '/../spec_helper'

describe "Task" do
  let(:task)   { Task.make! }
  let(:user)   { User.make! }
  let(:client) { Client.make! }

  describe "validations" do
    it "can be valid" do
      Task.make.should be_valid
    end
  end

  context "the timer" do
    before do
      @task1 = Task.make!(:client => client, :user => user)
      after(:each) { back_to_the_present }
      @now = Time.now
      @task1.start_timer
      time_travel_to(20.minutes.from_now)
      @task1.stop_timer
    end

    it "should add a completed shift for the task"
      @task1.completed_shifts.should_not be_empty
    end

    it "should add the duration between start and stop as the duration for the completed shift"
      shift1 = @task1.completed_shifts.first
      shift1.start_date.should eq(now)
      shift1.duration.should eq(20)
    end
  end
end